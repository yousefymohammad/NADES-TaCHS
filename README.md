# TaCHS-Aqueous-NADES-MD

Classical molecular dynamics simulations of chalcone synthase from *Triticum aestivum* (TaCHS) in water and aqueous natural deep eutectic solvent (NADES) environments.

This repository contains the simulation inputs, system-preparation files, and computational workflows used to investigate how aqueous NADES composition and concentration affect the structural dynamics, stability, and active-site environment of dimeric TaCHS. The simulated systems include choline chloride- and betaine-based NADES containing glycerol, ethylene glycol, or xylitol at different concentrations, together with a water control.


## Systems

| Directory | Solvent system | Available concentration labels |
| --- | --- | --- |
| `ChCl_Gly` | Choline chloride + glycerol | 10, 25, 50, 75 |
| `ChCl_EG` | Choline chloride + ethylene glycol | 10, 25, 50, 75 |
| `ChCl_Xyl` | Choline chloride + xylitol | 10, 25 |
| `Betaine_Gly` | Betaine + glycerol | 10, 25, 50, 75 |
| `Betaine_EG` | Betaine + ethylene glycol | 10, 25, 50, 75 |
| `nonades` | Water control | 1 |

The NADES labels correspond to the aqueous NADES percentages used in the
project. Exact molecular populations are recorded in each topology's
`[ molecules ]` section.

## Repository layout

```text
mdp/          GROMACS parameter files for minimization, equilibration, and MD
scripts/      Full production workflow and a short pipeline smoke test
structures/   Reference molecular and protein structures
systems/      Local user-prepared coordinate files (not tracked by Git)
topology/     System topologies, molecule parameters, restraints, and force field
```

The protocol was tested with GROMACS 2022.1. Coordinate (`.gro`) and compiled
run-input (`.tpr`) files under `systems/` are intentionally ignored because
they are large or version-dependent. Generate new `.tpr` files from the text
topology and `.mdp` inputs.

## Requirements

- GROMACS 2022.1 or a compatible version
- Bash
- A prepared, solvated, neutralized coordinate file for a new simulation
