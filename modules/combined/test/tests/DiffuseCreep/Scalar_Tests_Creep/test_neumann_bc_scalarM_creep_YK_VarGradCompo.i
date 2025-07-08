[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 500 #'${fparse int ( 2 * xmax / ${GlobalParams/int_width} ) }'
  xmin = 0
  xmax = 10
[]

[Variables]
  [c_v]
  []
  [jx_v]
  []
  [disp_x]
  []
[]

[Debug]
  # show_var_residual = true
  show_var_residual_norms = true
[]

[ICs]
  [./cv]
    type = ConstantIC
    value = 1e-6
    variable = c_v
  []
[]

[BCs]
  [left_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
  [source_left_x]
    type = NeumannBC
    variable = c_v
    boundary = 'left'
    value = 1e-5
  []
  [sink_right_x]
    type = NeumannBC
    variable = c_v
    boundary = 'right'
    value = -1e-5
  []

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
  [./flux_x]
    type = GradientComponent #Only solves expression J = -gradU (where D = 1)
    v = c_v
    variable = jx_v
    component = 0
    #
    #
  [../]
  [TensorMechanics]
    displacements = 'disp_x'
  []
[]

[Materials]
  [./DiffusivityMat]
    type = ADGenericConstantMaterial
    prop_names = D
    prop_values = 1e0
  [../]
# 
# 
# 
# 
#     
  [diffuse_strain_increment]
    type = FluxBasedStrainIncrement
    xflux = jx_v
    property_name = diffuse
    output_properties = diffuse_strain_00
    outputs = 'exodus'
  []
  [diffuse_creep_strain]
    type = SumTensorIncrements
    tensor_name = creep_strain
    coupled_tensor_increment_names = 'diffuse'
    outputs = 'exodus'
  []
  [./strain]
    type = ComputeIncrementalStrain
    displacements = 'disp_x'
  [../]
  [stress]
    type = ComputeStrainIncrementBasedStress
    inelastic_strain_names = creep_strain
  []
  [./elasticity_tensor]
    type = ComputeElasticityTensor
    C_ijkl = '120.0 80.0'
    fill_method = symmetric_isotropic
  [../]
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
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
  file_base = 1D_scalar
  checkpoint = true
[]
