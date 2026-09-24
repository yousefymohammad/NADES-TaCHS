#!/bin/bash

set -e

# Change these values to test another system.
NADES="Betaine_Gly"
CONCENTRATION="75"
TEST_STEPS="10"
CPU_THREADS="4"

# Uncomment this line if GROMACS must be loaded first.
# source /path/to/gromacs/bin/GMXRC

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MDP_DIR="${PROJECT_DIR}/mdp"
START_GRO="${PROJECT_DIR}/systems/${NADES}/start_${CONCENTRATION}.gro"
TOP_FILE="${PROJECT_DIR}/topology/${NADES}/topol_${CONCENTRATION}.top"
RUN_DIR="${PROJECT_DIR}/runs/smoke_test/${NADES}/${CONCENTRATION}"

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

echo "Testing ${NADES} at ${CONCENTRATION}% concentration"

# 1. Energy minimization
gmx grompp \
    -f "${MDP_DIR}/mini.mdp" \
    -c "$START_GRO" \
    -p "$TOP_FILE" \
    -o em_full.tpr

gmx convert-tpr -s em_full.tpr -o em.tpr -nsteps "$TEST_STEPS"
gmx mdrun -deffnm em -ntmpi 1 -ntomp "$CPU_THREADS"

# 2. First NVT equilibration
gmx grompp \
    -f "${MDP_DIR}/NVT.mdp" \
    -c em.gro \
    -r em.gro \
    -p "$TOP_FILE" \
    -o nvt_full.tpr

gmx convert-tpr -s nvt_full.tpr -o nvt.tpr -nsteps "$TEST_STEPS"
gmx mdrun -deffnm nvt -ntmpi 1 -ntomp "$CPU_THREADS"

# 3. Second NVT equilibration
gmx grompp \
    -f "${MDP_DIR}/NVT_1.mdp" \
    -c nvt.gro \
    -t nvt.cpt \
    -r nvt.gro \
    -p "$TOP_FILE" \
    -o nvt_1_full.tpr

gmx convert-tpr -s nvt_1_full.tpr -o nvt_1.tpr -nsteps "$TEST_STEPS"
gmx mdrun -deffnm nvt_1 -ntmpi 1 -ntomp "$CPU_THREADS"

# 4. Third NVT equilibration
gmx grompp \
    -f "${MDP_DIR}/NVT_2.mdp" \
    -c nvt_1.gro \
    -t nvt_1.cpt \
    -r nvt_1.gro \
    -p "$TOP_FILE" \
    -o nvt_2_full.tpr

gmx convert-tpr -s nvt_2_full.tpr -o nvt_2.tpr -nsteps "$TEST_STEPS"
gmx mdrun -deffnm nvt_2 -ntmpi 1 -ntomp "$CPU_THREADS"

# 5. Final NVT equilibration
gmx grompp \
    -f "${MDP_DIR}/NVT_3.mdp" \
    -c nvt_2.gro \
    -t nvt_2.cpt \
    -r nvt_2.gro \
    -p "$TOP_FILE" \
    -o nvt_3_full.tpr

gmx convert-tpr -s nvt_3_full.tpr -o nvt_3.tpr -nsteps "$TEST_STEPS"
gmx mdrun -deffnm nvt_3 -ntmpi 1 -ntomp "$CPU_THREADS"

# 6. NPT equilibration
gmx grompp \
    -f "${MDP_DIR}/npt.mdp" \
    -c nvt_3.gro \
    -t nvt_3.cpt \
    -r nvt_3.gro \
    -p "$TOP_FILE" \
    -o npt_full.tpr

gmx convert-tpr -s npt_full.tpr -o npt.tpr -nsteps "$TEST_STEPS"
gmx mdrun -deffnm npt -ntmpi 1 -ntomp "$CPU_THREADS"

# 7. Production MD
gmx grompp \
    -f "${MDP_DIR}/md_3.mdp" \
    -c npt.gro \
    -t npt.cpt \
    -p "$TOP_FILE" \
    -o md_1_full.tpr

gmx convert-tpr -s md_1_full.tpr -o md_1.tpr -nsteps "$TEST_STEPS"
gmx mdrun -deffnm md_1 -ntmpi 1 -ntomp "$CPU_THREADS"

echo
echo "Smoke test completed successfully."
echo "Output directory: $RUN_DIR"
echo
echo "Atom counts:"

for GRO_FILE in "$START_GRO" em.gro nvt.gro nvt_1.gro nvt_2.gro nvt_3.gro npt.gro md_1.gro; do
    sed -n '2p' "$GRO_FILE"
done
