# User Guide — Bacteria Motion Stokes Simulation

**Version:** 1.1.1  
**Updated:** 2026-08-18  
**Creator:** Lucien \<lucien-6@qq.com\>  

This guide explains how to run simulations, interpret outputs, and use post-processing tools for the flat V1.1.1 project layout.

---

## 1. What the code does

The solver builds a Stokeslet (regularized on pili) representation of a capsule bacterium, assembles a 6×6 friction matrix `FM`, then advances passive rigid-body motion under:

1. Buoyancy-corrected gravity (direction updated with quaternions)  
2. Diagonal Brownian force/torque from the fluctuation–dissipation relation using the decoupled friction matrix `DFM`

Each time step solves the mobility problem:

```text
F = [F_sink + F_Brownian; T_Brownian]
U = FM \ F
```

Geometry is built **once** before the time loop (static pili). Active swimming and pili length cycling are **not** enabled in V1.1.x.

---

## 2. Environment setup

1. Install MATLAB (R2020b+; verified on R2026a).  
2. Install toolboxes listed in `requirements.txt`.  
3. For post-processing color maps, add `MATLAB Add-On/2000 palettes/slanCL` to the MATLAB path (or install Add-On **2000 palettes**).  
4. `cd` to the project root (folder containing `Bacteria_Motion_Stokes_Simulation_Main.m`).

No `init_project_paths` is required in the flat layout — all `.m` files live in the project root.

---

## 3. Single simulation

### 3.1 Run

```matlab
Bacteria_Motion_Stokes_Simulation_Main
```

Default case name: `Test`  
Default duration: `TEnd = 10` s, `TStep = 0.01` s  
Default pili: `Pili_Matrix = zeros(8,0)` (no pili)

### 3.2 Edit before running

| Variable | Meaning |
|----------|---------|
| `Case_Name` | Output subfolder name under `Output_Path` |
| `Output_Path` | Default `./Results` |
| `Pili_Matrix` | See §5 |
| `TEnd`, `TStep` | Duration and step |
| `Nhead` | Body surface point count (cost ~ O(N²–N³) at setup) |
| `Temper`, `Density_F`, `Miu` | Fluid properties (default 30 °C water) |

Placeholders **without effect** in V1.1.x: `bodyU`, `U_tail`, `T_tail`.

### 3.3 Outputs (`Results/<Case_Name>/`)

| File | Content |
|------|---------|
| `<Case>.mat` | Workspace dump (positions, `FM`, logs, …) |
| `<Case>.log` | Diary log |
| `<Case>_Pos.mat` / `_Trajectory.jpg` | Trajectory |
| `<Case>_*.png` | Velocity / MSD figures |

Animation is **off** by default. To enable, uncomment the `Bacteria_Motion_Animations` block at the end of the Main script (MPEG-4).

### 3.4 Waitbar

Cancel via the waitbar button. Title shows `BMSS_V1.1.1`.

---

## 4. Batch simulation (`Run.m`)

1. Open `Run.m`.  
2. Set `Case`, `Pili_Matrix`, `TEnd`, and the loop `for no = ...`.  
   Default batch fluid is **20 °C water** (`Temper = 293.15`, `Density_F = 998.232`, `Miu = 0.001`), `TEnd = 200` s, `for no = 1:100`.  
3. Run:

```matlab
Run
```

Each replicate writes to `./Results/<Case>/<Case>_<nn>/`.  
Animation remains commented out for throughput.

---

## 5. Pili matrix

`Pili_Matrix` is 8×N (one column per pilus):

| Row | Meaning |
|-----|---------|
| 1 | Morphology: 1 linear, 2 parabolic, 3 circular, 4 expansive sine, 5 conical spiral |
| 2 | Length (µm) |
| 3 | Deflection about Z |
| 4 | Deflection about X |
| 5–7 | Shape parameters (`NaN` if unused) |
| 8 | Attachment locus (1–14) |

**No pili:**

```matlab
Pili_Matrix = zeros(8, 0);
```

Columns with non-positive length, or too few sample points after `ceil(L*ppp)`, are skipped.

---

## 6. Post-processing

### 6.1 `Motion_Data_Extract_Process`

```matlab
Motion_Data_Extract_Process
```

1. Select either a case folder that contains `<CaseName>_XX.mat`, or a parent folder of such cases.  
2. Script extracts `Pos` / `VM`, computes ensemble MSD, offset angle, fractal dimension, landing points, etc.  
3. Writes under `./Post-Processing/<Case_Name>/`, including `*_Motion Post-Data.mat`.

Requires `slanCL` on the path (asserted at plot time; bundled under `MATLAB Add-On/2000 palettes/slanCL`). Failed fractal fits become `NaN` and skip the FD figure.

### 6.2 `Organize_Summarize_Results_Data`

```matlab
Organize_Summarize_Results_Data
```

Pick a folder of post-processed cases containing `*_Motion Post-Data.mat`, then export sheets into `Final Data.xls`.

---

## 7. Numerical notes (V1.1.1)

- After assembling `M`, if `condest(M) > 1e16`, a warning is issued. Large condition numbers are common for fine discretizations; check `Nhead`, `shift`, and `epsA` if results look unstable.  
- Setup still builds and inverts the dense equilibrated system once to obtain `FM`; the time loop is cheap (`6×6`).  
- Brownian intensities use `diag(DFM)` only (no cross-correlation noise).

---

## 8. Troubleshooting

| Symptom | Likely cause | Action |
|---------|--------------|--------|
| `Unrecognized function or variable` | Wrong working directory | `cd` to project root |
| `slanCL not found` | Add-On missing / not on path | Add `MATLAB Add-On/2000 palettes/slanCL` to the MATLAB path |
| Ill-conditioned Green matrix warning | Fine mesh / geometry | Reduce `Nhead` or revisit `shift`/`epsA` |
| Changing `U_tail` has no effect | Not wired in V1.1.x | Expected; see Contract-branch for dynamics |
| Animation file / codec issues | Profile or empty frames | Use uncommented MPEG-4 path; ensure frames are written |

---

## 9. Related documents

- [`README.md`](../README.md) — overview  
- [`CHANGELOG.md`](../CHANGELOG.md) — release history  
- [`requirements.txt`](../requirements.txt) — MATLAB / toolbox list  
- [`VERSION`](../VERSION) — current version string  

---

**Last updated:** 2026-08-18  
