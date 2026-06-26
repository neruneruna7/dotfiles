use std::collections::HashSet;
use std::path::{Component, Path, PathBuf};

use shiguredo_toml::{Table, Value};

use crate::error::{DotfilesError, Result, invalid_config};
use crate::link_spec::LinkKind;

/// `dotfiles.toml` を検証済みの内部表現に変換した設定である。
///
/// TOML パーサ固有の `Value` や `Table` はこのモジュール内に閉じ込める。
/// そのため、他モジュールは TOML の構文ではなく、この型だけを前提にできる。
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Config {
    pub version: u32,
    pub policy: Policy,
    pub links: Vec<ConfiguredLink>,
}

/// 自動探索とリンク生成に適用するポリシーである。
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Policy {
    pub default_mapping: DefaultMapping,
    pub link_kind: LinkKind,
    pub ignore: Vec<String>,
}

/// dotfiles root 配下の相対パスを HOME 配下に鏡像配置する規則である。
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DefaultMapping {
    MirrorHome,
}

/// `[[links]]` で明示された例外リンクである。
///
/// この段階では相対パス検証だけを行い、絶対パスへの正規化は `link_spec` に委ねる。
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ConfiguredLink {
    pub source: PathBuf,
    pub target: PathBuf,
    pub kind: LinkKind,
}

/// `dotfiles.toml` の文字列を読み、検証済みの `Config` に変換する。
///
/// # Examples
///
/// ```
/// let config = dotfiles::config::parse_config(r#"
/// version = 1
///
/// [policy]
/// default_mapping = "mirror-home"
/// link_kind = "file"
/// ignore = [".local/**"]
/// "#).unwrap();
///
/// assert_eq!(config.version, 1);
/// assert_eq!(config.policy.ignore, vec![".local/**"]);
/// ```
pub fn parse_config(input: &str) -> Result<Config> {
    let table = shiguredo_toml::from_str(input)
        .map_err(|error| invalid_config(format!("failed to parse toml: {error}")))?;
    from_table(&table)
}

/// ファイルから `dotfiles.toml` を読み込む。
pub fn load_config(path: &Path) -> Result<Config> {
    let input = std::fs::read_to_string(path).map_err(|source| DotfilesError::Io {
        path: path.to_path_buf(),
        source,
    })?;
    parse_config(&input)
}

/// 設定ファイルが存在しない場合に使う既定設定である。
pub fn default_config() -> Config {
    Config {
        version: 1,
        policy: Policy {
            default_mapping: DefaultMapping::MirrorHome,
            link_kind: LinkKind::File,
            ignore: default_ignore(),
        },
        links: Vec::new(),
    }
}

/// MVP で常に探索対象外にする既定 ignore パターンである。
pub fn default_ignore() -> Vec<String> {
    [".git/**", "dotfiles.toml", "README*", "LICENSE*"]
        .into_iter()
        .map(String::from)
        .collect()
}

fn from_table(table: &Table) -> Result<Config> {
    let version = required_integer(table, "version")?;
    if version != 1 {
        return Err(invalid_config("version must be 1"));
    }

    let policy = required_table(table, "policy").and_then(parse_policy)?;
    let links = optional_links(table)?;
    reject_duplicate_targets(&links)?;

    Ok(Config {
        version: version as u32,
        policy,
        links,
    })
}

fn parse_policy(table: &Table) -> Result<Policy> {
    let default_mapping = match required_string(table, "default_mapping")? {
        "mirror-home" => DefaultMapping::MirrorHome,
        other => return Err(invalid_config(format!("unknown default_mapping: {other}"))),
    };
    let link_kind = parse_link_kind(required_string(table, "link_kind")?, "link_kind")?;
    let ignore = match table.get("ignore") {
        Some(Value::Array(values)) => values
            .iter()
            .map(|value| {
                value
                    .as_str()
                    .map(String::from)
                    .ok_or_else(|| invalid_config("policy.ignore must contain only strings"))
            })
            .collect::<Result<Vec<_>>>()?,
        Some(_) => return Err(invalid_config("policy.ignore must be an array")),
        None => Vec::new(),
    };

    Ok(Policy {
        default_mapping,
        link_kind,
        ignore,
    })
}

fn optional_links(table: &Table) -> Result<Vec<ConfiguredLink>> {
    let Some(value) = table.get("links") else {
        return Ok(Vec::new());
    };
    let Value::Array(items) = value else {
        return Err(invalid_config("links must be an array of tables"));
    };

    items
        .iter()
        .map(|item| {
            let Some(link_table) = item.as_table() else {
                return Err(invalid_config("links must be an array of tables"));
            };
            let source = validate_source(required_string(link_table, "source")?)?;
            let target = validate_target(required_string(link_table, "target")?)?;
            let kind = optional_link_kind(link_table)?;
            Ok(ConfiguredLink {
                source,
                target,
                kind,
            })
        })
        .collect()
}

fn optional_link_kind(table: &Table) -> Result<LinkKind> {
    match table.get("kind") {
        Some(value) => parse_link_kind(
            value
                .as_str()
                .ok_or_else(|| invalid_config("links[].kind must be a string"))?,
            "links[].kind",
        ),
        None => Ok(LinkKind::File),
    }
}

fn required_integer(table: &Table, key: &str) -> Result<i64> {
    table
        .get(key)
        .ok_or_else(|| invalid_config(format!("missing key: {key}")))?
        .as_integer()
        .ok_or_else(|| invalid_config(format!("{key} must be an integer")))
}

fn required_string<'a>(table: &'a Table, key: &str) -> Result<&'a str> {
    table
        .get(key)
        .ok_or_else(|| invalid_config(format!("missing key: {key}")))?
        .as_str()
        .ok_or_else(|| invalid_config(format!("{key} must be a string")))
}

fn required_table<'a>(table: &'a Table, key: &str) -> Result<&'a Table> {
    table
        .get(key)
        .ok_or_else(|| invalid_config(format!("missing key: {key}")))?
        .as_table()
        .ok_or_else(|| invalid_config(format!("{key} must be a table")))
}

fn parse_link_kind(value: &str, field: &str) -> Result<LinkKind> {
    match value {
        "file" => Ok(LinkKind::File),
        "directory" => Ok(LinkKind::Directory),
        other => Err(invalid_config(format!("unknown {field}: {other}"))),
    }
}

fn validate_source(source: &str) -> Result<PathBuf> {
    validate_non_empty_path("source", source)?;
    let path = PathBuf::from(source);
    if path.is_absolute() {
        return Err(invalid_config("source must be relative"));
    }
    if contains_parent(&path) {
        return Err(invalid_config("source must not contain .."));
    }
    Ok(path)
}

fn validate_target(target: &str) -> Result<PathBuf> {
    validate_non_empty_path("target", target)?;
    let path = PathBuf::from(target);
    if contains_parent(&path) {
        return Err(invalid_config("target must not contain .."));
    }
    Ok(path)
}

fn validate_non_empty_path(field: &str, value: &str) -> Result<()> {
    if value.trim().is_empty() {
        Err(invalid_config(format!("{field} must not be empty")))
    } else {
        Ok(())
    }
}

fn contains_parent(path: &Path) -> bool {
    path.components()
        .any(|component| matches!(component, Component::ParentDir))
}

fn reject_duplicate_targets(links: &[ConfiguredLink]) -> Result<()> {
    let mut targets = HashSet::new();
    for link in links {
        if !targets.insert(link.target.clone()) {
            return Err(DotfilesError::DuplicateTarget(link.target.clone()));
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn valid_config() -> &'static str {
        r#"
version = 1

[policy]
default_mapping = "mirror-home"
link_kind = "file"
"#
    }

    #[test]
    fn version_1_can_be_loaded() {
        let config = parse_config(valid_config()).unwrap();
        assert_eq!(config.version, 1);
    }

    #[test]
    fn missing_version_is_config_error() {
        let err = parse_config(
            r#"
[policy]
default_mapping = "mirror-home"
link_kind = "file"
"#,
        )
        .unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn unsupported_version_is_config_error() {
        let err = parse_config(&valid_config().replace("version = 1", "version = 2")).unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn missing_policy_is_config_error() {
        let err = parse_config("version = 1").unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn mirror_home_policy_can_be_loaded() {
        let config = parse_config(valid_config()).unwrap();
        assert_eq!(config.policy.default_mapping, DefaultMapping::MirrorHome);
    }

    #[test]
    fn unknown_default_mapping_is_config_error() {
        let err = parse_config(&valid_config().replace("mirror-home", "flat")).unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn file_link_kind_can_be_loaded() {
        let config = parse_config(valid_config()).unwrap();
        assert_eq!(config.policy.link_kind, LinkKind::File);
    }

    #[test]
    fn missing_ignore_becomes_empty_list() {
        let config = parse_config(valid_config()).unwrap();
        assert!(config.policy.ignore.is_empty());
    }

    #[test]
    fn string_ignore_entries_can_be_loaded() {
        let config = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
ignore = [".local/**", ".cache/**"]
"#,
        )
        .unwrap();

        assert_eq!(config.policy.ignore, vec![".local/**", ".cache/**"]);
    }

    #[test]
    fn non_string_ignore_entry_is_config_error() {
        let err = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
ignore = [1]
"#,
        )
        .unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn multiple_links_can_be_loaded() {
        let config = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"

[[links]]
source = ".config/git/config"
target = ".gitconfig"

[[links]]
source = ".config/app/config.toml"
target = ".config/app/config.toml"
"#,
        )
        .unwrap();
        assert_eq!(config.links.len(), 2);
    }

    #[test]
    fn link_kind_directory_can_be_loaded() {
        let config = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
source = ".config/helix"
target = ".config/helix"
kind = "directory"
"#,
        )
        .unwrap();

        assert_eq!(config.links[0].kind, LinkKind::Directory);
    }

    #[test]
    fn link_kind_file_can_be_loaded() {
        let config = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
source = ".config/git/config"
target = ".gitconfig"
kind = "file"
"#,
        )
        .unwrap();

        assert_eq!(config.links[0].kind, LinkKind::File);
    }

    #[test]
    fn omitted_link_kind_defaults_to_file() {
        let config = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
source = ".config/git/config"
target = ".gitconfig"
"#,
        )
        .unwrap();

        assert_eq!(config.links[0].kind, LinkKind::File);
    }

    #[test]
    fn unknown_link_kind_is_config_error() {
        let err = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
source = ".config/git/config"
target = ".gitconfig"
kind = "socket"
"#,
        )
        .unwrap_err();

        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn link_without_source_is_config_error() {
        let err = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
target = ".gitconfig"
"#,
        )
        .unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn link_without_target_is_config_error() {
        let err = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
source = ".config/git/config"
"#,
        )
        .unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn empty_source_is_config_error() {
        let err = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
source = ""
target = ".gitconfig"
"#,
        )
        .unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn empty_target_is_config_error() {
        let err = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
source = ".config/git/config"
target = ""
"#,
        )
        .unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn absolute_source_is_config_error() {
        let err = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
source = "/tmp/config"
target = ".gitconfig"
"#,
        )
        .unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn source_with_parent_component_is_config_error() {
        let err = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
source = "../config"
target = ".gitconfig"
"#,
        )
        .unwrap_err();
        assert!(matches!(err, DotfilesError::InvalidConfig(_)));
    }

    #[test]
    fn duplicate_target_is_config_error() {
        let err = parse_config(
            r#"
version = 1
[policy]
default_mapping = "mirror-home"
link_kind = "file"
[[links]]
source = ".a"
target = ".same"
[[links]]
source = ".b"
target = ".same"
"#,
        )
        .unwrap_err();
        assert!(matches!(err, DotfilesError::DuplicateTarget(_)));
    }
}
