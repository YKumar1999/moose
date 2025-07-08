
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 500
  xmin = 0
  xmax = 10
[]

[Variables]
  [./Cv]
  [../]
  [./jx]
  [../]
  [./disp_x]
  [../]
[]

[Debug]
  # show_var_residual = true
  show_var_residual_norms = true
[]

[ICs]
  [./Cv]
    type = ConstantIC
    value = 1e-6
    variable = Cv
  []
[]

[BCs]
  [./fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  [../]
  [./left_source_Cv]
    type = NeumannBC
    boundary = left
    variable = Cv
    value = 1e-5
  []
  [./right_sink_Cv]
    type = NeumannBC
    boundary = right
    variable = Cv
    value = -1e-5
  []
[]

[Kernels]
  [./c]
    type = ADMatDiffusion
    variable = Cv
    diffusivity = D
  [../]
  [./time]
    type = TimeDerivative
    variable = Cv
  [../]
  [./flux_x]
    type = CHSplitFlux
    variable = jx
    component = 0
    mobility_name = Dtensor
    mu = Cv
    c = Cv
  [../]
  [./TensorMechanics]
    displacements = 'disp_x'
  [../]
[]

[Materials]
  [./DiffusivityMat]
    type = ADGenericConstantMaterial
    prop_names = D
    prop_values = 1e0
  [../]
  [./diffusivity]
    type = GBDependentDiffusivity
    bulk_parameter = 1
    gb_tensor_prop_name = Dtensor
  [../]
  [./diffuse_strain_increment]
    type = FluxBasedStrainIncrement
    xflux = jx
    property_name = diffuse_strain
    output_properties = diffuse_strain_00
    outputs = 'exodus'
  [../]
  [./creep_strain]
    type = SumTensorIncrements
    tensor_name = creep_strain
    coupled_tensor_increment_names = 'diffuse_strain'
    outputs = 'exodus'
  [../]
  [./strain]
   type = ComputeIncrementalStrain
    displacements = 'disp_x'
  [../]
  [./stress]
    type = ComputeStrainIncrementBasedStress
    inelastic_strain_names = creep_strain
  [../]
  [./elasticity_tensor]
    type = ComputeElasticityTensor
    C_ijkl = '120.0 80.0'
    fill_method = symmetric_isotropic
  [../]
[]

[Preconditioning]
  [./smp]
     type = SMP
     full = true
  [../]
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
  file_base = 1D_tensor
  checkpoint = true
[]
