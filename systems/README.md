# Local system files

Prepare each solvated and neutralized coordinate file locally and name it:

```text
<NADES>/start_<concentration>.gro
```

For example, `ChCl_Gly/start_50.gro` is used with
`../topology/ChCl_Gly/topol_50.top`. The coordinate ordering and molecular
populations must match the topology. Coordinate and compiled `.tpr` files in
the system subdirectories are ignored by Git.
