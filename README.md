# nObjectsEngine

A high-performance $N$-body gravitational physics engine written in Haskell. `nObjectsEngine` simulates gravitational dynamics across multi-body systems—ranging from two-body Kepler orbits to chaotic three-body presets—with strict energy conservation integrators and streaming CSV trajectory output, which is used to visualize orbital paths in python.

---

## Technical & Physics Architecture

* **Gravitational Field Evaluation:** Computes pairwise Newtonian gravity with a Plummer softening parameter ($\epsilon$) to prevent numerical singularities during close stellar encounters:
  $$\mathbf{F}_{ij} = -G \frac{m_i m_j}{(\Vert{}\mathbf{r}_{ij}\Vert{}^2 + \epsilon^2)^{3/2}} \mathbf{r}_{ij}$$
* **Symplectic Integrator:** Employs semi-implicit **Euler-Cromer integration** (updating velocity prior to position) to maintain phase-space volume preservation and bound long-term orbital energy drift.
* **Conservation Monitoring:** Computes total mechanical energy ($E = K + U$) at every step to quantify relative numerical drift over simulation horizons:
  $$K = \sum \frac{1}{2}m_i \Vert{}\mathbf{v}_i\Vert{}^2, \quad U = -\sum_{i < j} \frac{G m_i m_j}{\sqrt{\Vert{}\mathbf{r}_{ij}\Vert{}^2 + \epsilon^2}}$$

---

## File Structure

```text
nObjectsEngine/
├── app/
│   └── Main.hs             #Command line parsinhg and main execution logic
├── src/
│   ├── Math/
│   │   └── Vector3.hs      #3D vector functions
│   └── Physics/
│       ├── Types.hs        #Body and system state definitions
│       ├── Forces.hs       #Gravitational acceleration calculation
│       ├── Integrator.hs   #Euler-cromer evaluation and energy functions
│       ├── Simulator.hs    #Lazy simulation streaming and CSV Parsing
│       └── Presets.hs      #Presets(Figure 8 and Plummer Sphere)
├── test/
│   └── Spec.hs             #Quickcheck property tests and Kepler energy conservation test
├── output/                 #CSV trajectory data
└── nObjectsEngine.cabal    #Cabal build config
```
---

Tools & Tech Stack
• Language: Haskell (GHC 9.10+)
• Build System: Cabal
• CLI Library: optparse-applicative
• Randomization: System.Random (Plummer distribution sampling)
• Testing: QuickCheck (Property testing)
Setup & Building
Ensure GHC and Cabal are installed on your system.

# Clone repository
git clone [https://github.com/your-username/nObjectsEngine.git](https://github.com/your-username/nObjectsEngine.git)
cd nObjectsEngine

# Build project library and executable
cabal build

# Run test suite
cabal test --test-show-details=direct

Running Simulations
Run the executable with Cabal and customize parameters using command-line options:
# 1. Earth-Sun Kepler Orbit (Default)
cabal run nObjectsEngine

# 2. Figure-8 Three-Body Choreography
cabal run nObjectsEngine -- --preset figure8 --steps 5000 --dt 0.001 -o output/figure8.csv

# 3. Plummer Sphere Galactic Cluster (250 Bodies)
cabal run nObjectsEngine -- --preset plummer --bodies 250 --steps 2000 -o output/cluster.csv

# Display CLI Help Options
cabal run nObjectsEngine -- --help

Output Data Format
Simulation outputs stream line-by-line to CSV with the following header layout:
time,id,mass,pos_x,pos_y,pos_z,vel_x,vel_y,vel_z