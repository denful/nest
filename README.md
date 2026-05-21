<p align="right">
  <a href="https://dendritic.oeiuwq.com/sponsor"><img src="https://img.shields.io/badge/sponsor-vic-white?logo=githubsponsors&logoColor=white&labelColor=%23FF0000" alt="Sponsor Vic"/></a>
  <a href="https://deepwiki.com/denful/nest"><img src="https://deepwiki.com/badge.svg" alt="Ask DeepWiki"></a>
  <a href="https://github.com/denful/den/releases"><img src="https://img.shields.io/github/v/release/denful/nest?style=plastic&logo=github&color=purple"/></a>
  <a href="https://dendritic.oeiuwq.com"><img src="https://img.shields.io/badge/Dendritic-Nix-informational?logo=nixos&logoColor=white" alt="Dendritic Nix"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/denful/nest" alt="License"/></a>
  <a href="https://github.com/denful/nest/actions"><img src="https://github.com/denful/nest/actions/workflows/test.yml/badge.svg" alt="CI Status"/></a>
</p>

> nest and [vic](https://bsky.app/profile/oeiuwq.bsky.social)'s [dendritic libs](https://dendritic.oeiuwq.com) made for you with Love++ and AI--. If you like my work, consider [sponsoring](https://dendritic.oeiuwq.com/sponsor)


<table>
<tr>
<td>


# Nest

Nest is a declarative framework for multi-node NixOS infrastructure. It applies the CSS mental model to system configuration: nodes are entities in a DOM tree, traits are classes, and rules map selectors to configuration.


See the Annotated Example [templates/default](./templates/default); Recommended read order: [`traits.nix`](./templates/default/modules/traits.nix) -> [`dom.nix`](./templates/default/modules/dom.nix) -> [`rules/*.nix`](./templates/default/modules/rules) -> [`outs.nix`](./templates/default/modules/outs.nix).

CI [tests](./tests/) and [fleet-demo](./templates/fleet-demo/)


</td>

<td>

### Documentation: [nest.denful.dev](https://nest.denful.dev)

<img src="https://raw.githubusercontent.com/denful/nest/refs/heads/main/docs/public/nest.png">

</td>
</tr>
</table>

---


## Design

**Infrastructure as a DOM.** Your fleet lives in an attrset hierarchy that mirrors tree mental model — environments, roles, regions. Parents propagate scalar attributes to children, so you set `system` or `env` once at a subtree root and every node beneath inherits it.

**Traits over repetition.** Traits classify nodes and form dependency DAGs. Declaring a node as `server` can automatically pull in `nginx`, `ssh`, and `firewall` via `needs`. `neededBy` works in reverse — a monitoring trait can inject itself into every matching node without those nodes knowing it exists.

**Rules over inheritance chains.** Rules match nodes via selectors and contribute NixOS or other Dendritic Nix module fragments. Nest collects those fragments as a list and passes them directly to `nixosSystem` — the NixOS module system handles merging. This means `lib.mkForce`, `lib.mkDefault`, type checking, and conflict detection all work exactly as they do in hand-written configurations.

**CSS selectors for targeting.** The selection model composes: match by trait, by name, by attribute value, by DOM ancestry, by predicate, or any boolean combination. String-based CSS syntax (`#lb-prod`, `.nixos`, `[env=prod]`, `prod > web`) is also supported for familiarity.

**Synthesis for derived data.** Allows computing derived node attributes and injecting virtual children. A host can synthesize data from its children or any other node in the DOM. Derived structure participates in rule matching like any other node.




