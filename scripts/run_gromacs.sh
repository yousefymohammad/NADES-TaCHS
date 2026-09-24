#!/bin/bash

set -e

# Change these values for the simulation you want to run.
NADES="Betaine_Gly"
CONCENTRATION="75"
GPU_ID="0"

# Uncomment one of these lines if GROMACS must be loaded first.
# module load cuda/12.2
# source /path/to/gromacs/bin/GMXRC

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MDP_DIR="${PROJECT_DIR}/mdp"
# The user prepares and neutralizes this structure before running the workflow.
START_GRO="${PROJECT_DIR}/systems/${NADES}/start_${CONCENTRATION}.gro"
TOP_FILE="${PROJECT_DIR}/topology/${NADES}/topol_${CONCENTRATION}.top"
RUN_DIR="${PROJECT_DIR}/runs/${NADES}/${CONCENTRATION}"

if [ ! -f "$START_GRO" ]; then
    echo "Error: starting structure not found: $START_GRO"
    exit 1
fi

if [ ! -f "$TOP_FILE" ]; then
    echo "Error: topology not found: $TOP_FILE"
    exit 1
fi

mkdir -p "$RUN_DIR"
cd "$RUN_DIR"

echo "Running ${NADES} at ${CONCENTRATION}% concentration"

# 1. Energy minimization
gmx grompp \
    -f "${MDP_DIR}/mini.mdp" \
    -c "$START_GRO" \
    -p "$TOP_FILE" \
    -o em.tpr

gmx mdrun -deffnm em -gpu_id "$GPU_ID" -v

# 2. First NVT equilibration
gmx grompp \
    -f "${MDP_DIR}/NVT.mdp" \
    -c em.gro \
    -r em.gro \
    -p "$TOP_FILE" \
    -o nvt.tpr

gmx mdrun -deffnm nvt -gpu_id "$GPU_ID" -v

# 3. Second NVT equilibration
gmx grompp \
    -f "${MDP_DIR}/NVT_1.mdp" \
    -c nvt.gro \
    -t nvt.cpt \
    -r nvt.gro \
    -p "$TOP_FILE" \
    -o nvt_1.tpr

gmx mdrun -deffnm nvt_1 -gpu_id "$GPU_ID" -v

# 4. Third NVT equilibration
gmx grompp \
    -f "${MDP_DIR}/NVT_2.mdp" \
    -c nvt_1.gro \
    -t nvt_1.cpt \
    -r nvt_1.gro \
    -p "$TOP_FILE" \
    -o nvt_2.tpr

gmx mdrun -deffnm nvt_2 -gpu_id "$GPU_ID" -v

# 5. Final NVT equilibration
gmx grompp \
    -f "${MDP_DIR}/NVT_3.mdp" \
    -c nvt_2.gro \
    -t nvt_2.cpt \
    -r nvt_2.gro \
    -p "$TOP_FILE" \
    -o nvt_3.tpr

gmx mdrun -deffnm nvt_3 -gpu_id "$GPU_ID" -v

# 6. NPT equilibration
gmx grompp \
    -f "${MDP_DIR}/npt.mdp" \
    -c nvt_3.gro \
    -t nvt_3.cpt \
    -r nvt_3.gro \
    -p "$TOP_FILE" \
    -o npt.tpr

gmx mdrun -deffnm npt -gpu_id "$GPU_ID" -v

# 7. Production MD
gmx grompp \
    -f "${MDP_DIR}/md_3.mdp" \
    -c npt.gro \
    -t npt.cpt \
    -p "$TOP_FILE" \
    -o md_1.tpr

gmx mdrun -deffnm md_1 -gpu_id "$GPU_ID" -v
