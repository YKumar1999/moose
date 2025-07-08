[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 25
  ny = 25
  xmin = -50
  xmax = 50
  ymin = -50
  ymax = 50
[]

[Variables]
  [c_v]
  []
[]

[ICs]
  [./cv]
    type = ConstantIC
    value = 1e-6
    variable = c_v
  []
[]

[Debug]
  # show_var_residual = true
  show_var_residual_norms = true
[]

[Kernels]
  [./c]
    type = ADMatDiffusion
    variable = c_v
    diffusivity = D
  [../]
  [dc_dt]
    type = TimeDerivative
    variable = c_v
  []
[]

[BCs]
  [source_top_y]
    type = MatNeumannBC
    variable = c_v
    boundary = 'top'
    value = 1
    boundary_material = neumann_source_top_y
  []
  [source_right_x]
    type = MatNeumannBC
    variable = c_v
    boundary = 'right'
    value = 1
    boundary_material = neumann_source_right_x
  []
  [source_bottom_y]
    type = MatNeumannBC
    variable = c_v
    boundary = 'bottom'
    value = 1
    boundary_material = neumann_source_bottom_y
  []
  [source_left_x]
    type = MatNeumannBC
    variable = c_v
    boundary = 'left'
    value = 1
    boundary_material = neumann_source_left_x
  []
[]

[Materials]
  [./DiffusivityMat]
    type = ADGenericConstantMaterial
    prop_names = D
    prop_values = 1
  [../]
  [./DiffusivityMat_nonAD]
    type = GenericConstantMaterial
    prop_names = D_nonAD
    prop_values = 1
  [../]
 [neumann_source_top_y] # +ve for entering
    type = ParsedMaterial
    expression = '1.5e-5' 
    property_name = neumann_source_top_y
    outputs = exodus
  []
  [neumann_source_right_x]
    type = ParsedMaterial
    expression = '-1.5e-5' #Sign Change 
    property_name = neumann_source_right_x
    outputs = exodus
  []
  [neumann_source_bottom_y] # +ve for entering
    type = ParsedMaterial
    expression = '1.5e-5' 
    property_name = neumann_source_bottom_y
    outputs = exodus
  []
  [neumann_source_left_x]
    type = ParsedMaterial
    expression = '-1.5e-5' #Sign Change 
    property_name = neumann_source_left_x
    outputs = exodus
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    # full = true
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu superlu_dist'
  # petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  # petsc_options_value = 'hypre    boomeramg      31                 0.7'
  # petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  # petsc_options_value = 'asm      31                  preonly       lu           2'
  l_tol = 1e-4 #1e-3
  l_max_its = 100
  nl_abs_tol = 1e-9
  end_time = 1e5
  dt = 0.1

  # [Adaptivity]
  #   max_h_level = 2
  #   refine_fraction = 0.3
  #   coarsen_fraction = 0.2
  # []

  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-6
    iteration_window = 2
    optimal_iterations = 9
    growth_factor = 1.25
    cutback_factor = 0.8
  []
  dtmax = 1e5
  # end_time = 100
[]

[Outputs]
  exodus = true
  checkpoint = true
  file_base = Test #2D_Scalar_Square_OffDiagonal_NBC_SourceSink
[]
