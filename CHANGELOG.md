# Changelog

All notable changes to this project are documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/).
Versioning follows [Semantic Versioning](https://semver.org/).

## [1.1.0] - 2026-07-31

### Fixed
- Zero angular increment in `Sink_Force_Update` no longer produces NaN quaternions / sinking-force vectors.
- True no-pili configuration via `Pili_Matrix = zeros(8,0)`; non-positive lengths and under-sampled pili columns are skipped safely.
- `Offset_Ratio` now fills column 2 (lateral/axial ratio) with protection for near-zero axial means.
- `Calculate_Fractal_Dimension` returns `NaN` on degenerate trajectories and caps recursive size-ratio retries (`maxDepth = 5`).
- Animation writer uses explicit `MPEG-4` profile; frame rate capped to a practical range.

### Changed
- Time loop mobility solve uses precomputed `FM \ F` instead of repeated dense `(3N+6)` solves (numerically equivalent within ~1e-16 relative error in verification).
- `Force_Log` now stores the applied generalized force/torque (gravity + Brownian), not Stokeslet-reconstructed loads.
- Large Green-matrix factors are cleared after friction-matrix assembly to reduce memory use.
- `Motion_Data_Extract_Process` selects case folders via dialog and derives `Case_Name` with `fileparts` (no hardcoded path slice).
- Main-program animation generation is disabled by default (can be uncommented).

### Added
- Ill-conditioning warning when `condest(M) > 1e16`.
- Explicit notes that `bodyU` / `U_tail` / `T_tail` are unused in this flat V1.1 build (active pili dynamics not merged).
- Project documentation set: `README.md`, `requirements.txt`, `CHANGELOG.md`, `docs/USER_GUIDE.md`, `VERSION`.

### Notes
- Active swimming / pili extension–contraction dynamics remain out of scope for V1.1; see Contract-branch modules for that capability.
- Post-processing trajectory coloring still depends on the `slanCL` MATLAB Add-On.

## [1.0.0] - 2024-12-23

### Added
- Flat-layout Stokes / Brownian bacterial sinking simulator (commit `3ac2693`, Periodic Backup).
- Capsule body + multi-morphology pili geometry.
- Regularized Stokeslet friction matrix, quaternion attitude update, MSD analysis.
- Batch runner `Run.m` and post-processing scripts.

[1.1.0]: https://github.com/Lucien-6/Bacterial_Sinking_Simulation/compare/3ac2693...HEAD
[1.0.0]: https://github.com/Lucien-6/Bacterial_Sinking_Simulation/tree/3ac2693
