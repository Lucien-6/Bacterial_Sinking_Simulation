# Bacteria Motion Stokes Simulation

**Version:** 1.1.1  
**Updated:** 2026-08-18  
**Creator:** Lucien  
**Email:** lucien-6@qq.com  

Low-Reynolds-number (Stokes) numerical simulation of capsule-shaped bacteria in liquid, including gravitational sinking, Brownian forcing, and optional static pili geometry. Based on work originating from Prof. Yang Ding (Beijing Computational Science Research Center), rewritten and extended by Lucien.

---

## Features (V1.1.1)

- Capsule body point-cloud modeling with inward-shifted force points
- Static pili geometry (5 morphologies, 14 body loci); true no-pili via `zeros(8,0)`
- Regularized Stokeslet Green matrix → 6×6 friction / mobility matrix
- Gravity + diagonal Brownian forcing with quaternion attitude updates
- Trajectory, velocity, and MSD analysis; optional MPEG-4 animation
- Batch runs (`Run.m`) and case post-processing
- Vendored `slanCL` palettes under `MATLAB Add-On/2000 palettes/`

**Not included in V1.1.x:** active body swimming (`bodyU`) and pili extension/contraction (`U_tail` / `T_tail`). Those parameters are placeholders only.

---

## Requirements

See [`requirements.txt`](requirements.txt).

| Item | Notes |
|------|--------|
| MATLAB | Verified on R2026a; R2020b+ recommended |
| Curve Fitting Toolbox | MSD / box-count fits |
| Statistics and Machine Learning Toolbox | `nlinfit` in post-processing |
| Add-On `slanCL` | Trajectory color palettes; bundled at `MATLAB Add-On/2000 palettes/slanCL` |

---

## Quick start

```matlab
cd('F:\Bacteria Sinking\Simulation\Stokes Brown')   % project root
Bacteria_Motion_Stokes_Simulation_Main              % single short Test case
```

Batch example:

```matlab
cd('F:\Bacteria Sinking\Simulation\Stokes Brown')
Run    % edit Case / loop range inside Run.m first
```

Post-processing:

```matlab
Motion_Data_Extract_Process   % pick a case folder or parent of cases
Organize_Summarize_Results_Data
```

Full usage details: [`docs/USER_GUIDE.md`](docs/USER_GUIDE.md).

---

## Project layout (flat)

| File / folder | Role |
|---------------|------|
| `Bacteria_Motion_Stokes_Simulation_Main.m` | Single-run entry |
| `Run.m` | Serial batch entry |
| `Capsule_Body_Building.m` … `Assemble_Body_Pilis.m` | Geometry |
| `Original_Green_Function_Matrix.m` … `Decouping_Friction_Matrix.m` | Stokes solver |
| `Sink_Force_Update.m` … `Calculate_Motion_Trajectory.m` | Kinematics |
| `Calculate_Velocity_MSD.m` … `Offset_Ratio.m` | Analysis helpers |
| `Bacteria_Motion_Animations.m` | Optional MPEG-4 animation |
| `Motion_Data_Extract_Process.m` | Batch post-processing |
| `docs/USER_GUIDE.md` | User guide |
| `CHANGELOG.md` | Version history |
| `VERSION` | Current version string |
| `MATLAB Add-On/2000 palettes/` | Vendored `slanCL` palettes for post-processing |

Outputs default to `./Results/` (simulations) and `./Post-Processing/` (analysis).

---

## Key parameters

```matlab
% Fluid — Main Test default: water at 30 °C
Temper = 303.15;  Density_F = 995.676;  Miu = 0.0008007;
% Fluid — Run.m batch default: water at 20 °C
% Temper = 293.15;  Density_F = 998.232;  Miu = 0.001;

% Capsule body
major_axis = 1.25e-6;  minor_axis = 0.4e-6;  Nhead = 1000;

% Pili: true none
Pili_Matrix = zeros(8, 0);
% Or columns: [type; length_um; ...; locus 1-14]

TStep = 0.01;  TEnd = 10;    % Main Test defaults
% TEnd = 200;                 % Run.m batch default
```

Time loop uses the precomputed mobility relation `U = FM \ F` (gravity + Brownian).

---

## Versioning

| Version | Date | Summary |
|---------|------|---------|
| 1.1.1 | 2026-08-18 | Batch 20 °C fluid defaults; vendored `slanCL` add-on |
| 1.1.0 | 2026-07-31 | Robustness & performance maintenance release |
| 1.0.0 | 2024-12-23 | Flat-layout baseline (`Periodic Backup`) |

See [`CHANGELOG.md`](CHANGELOG.md).

---

## License

MIT License (see repository / distribution terms as applicable).

---

## Contact

**Creator:** Lucien  
**Email:** lucien-6@qq.com  
