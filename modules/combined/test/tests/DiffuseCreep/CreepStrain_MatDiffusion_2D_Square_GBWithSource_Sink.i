
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  xmin = 0
  xmax = 50
  ymin = 0
  ymax = 50
[]

[Variables]
  [./Cv]
    # scaling = 1e-10
  [../]
  # [./mu]
  # []
  [./jx]
  [../]
  [./jy]
  [../]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
[]

[Debug]
  # show_var_residual = true
  show_var_residual_norms = true
[]

[AuxVariables]
  [./creep_strain_xx]
    family = MONOMIAL
    order  = CONSTANT
  [../]
  [./creep_strain_yy]
    family = MONOMIAL
    order  = CONSTANT
  [../]
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
  [./flux_y]
    type = CHSplitFlux
    variable = jy
    component = 0
    mobility_name = Dtensor
    mu = Cv
    c = Cv
  [../]
  # [./chempot]
  #   type = CHSplitChemicalPotential
  #   variable = mu
  #   chemical_potential_prop = mu_prop
  #   c = Cv
  # [../]
  [./TensorMechanics]
    displacements = 'disp_x disp_y'
  [../]
[]

[AuxKernels]
  [./creep_strain_xx]
    type = RankTwoAux
    variable = creep_strain_xx
    rank_two_tensor = creep_strain
    index_i = 0
    index_j = 0
  [../]
  [./creep_strain_yy]
    type = RankTwoAux
    variable = creep_strain_yy
    rank_two_tensor = creep_strain
    index_i = 0
    index_j = 0
  [../]
[]

[ICs]
  [./Cv]
    type = ConstantIC
    value = 1e-6
    variable = Cv
  []
[]

[Materials]

  # [./chemical_potential]
  #   type = DerivativeParsedMaterial
  #   block = 0
  #   property_name = mu_prop
  #   coupled_variables = Cv
  #   expression = 'Cv-0.2'
  #   derivative_order = 1
  # [../]

  #Sources and Sink Terms

  [neumann_source_top_y] # +ve for entering
    type = ParsedMaterial
    expression = '1.5e-5' 
    property_name = neumann_source_top_y
    outputs = exodus
  []
  [neumann_sink_right_x]
    type = ParsedMaterial
    expression = '-1.5e-5' 
    property_name = neumann_sink_right_x
    outputs = exodus
  []

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
    yflux = jy
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
    displacements = 'disp_x disp_y'
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

[BCs]
  [./fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  [../]
  [./fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = top
    value = 0
  [../]
  [source_top_y]
    type = MatNeumannBC
    variable = Cv
    boundary = 'top'
    value = 1
    boundary_material = neumann_source_top_y
  []
  [sink_right_x]
    type = MatNeumannBC
    variable = Cv
    boundary = 'right'
    value = 1
    boundary_material = neumann_sink_right_x
  []
  # [./left_source_Cv]
  #   type = NeumannBC
  #   boundary = left
  #   variable = Cv
  #   value = 1e-5
  # []
  # [./right_sink_Cv]
  #   type = NeumannBC
  #   boundary = right
  #   variable = Cv
  #   value = -1e-5
  # []
[]

# [Executioner]
#   type = Transient
#   solve_type = PJFNK

#   petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
#   petsc_options_value = 'asm      31                  preonly       ilu           1'

#   # automatic_scaling = false

#   nl_rel_tol = 1e-10
#   nl_max_its = 5

#   l_tol = 1e-4
#   l_max_its = 20
#   end_time = 1e8

#   dt = 0.001
#   # num_steps = 100
# []
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

# [Executioner]
#   type = Transient
#   solve_type = PJFNK

#   petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
#   petsc_options_value = 'asm      31                  preonly       lu           1'

#   automatic_scaling = true

#   nl_rel_tol = 1e-10
#   nl_max_its = 5

#   l_tol = 1e-7
#   l_max_its = 20
#   end_time = 1e8

#   [TimeStepper]
#     type = IterationAdaptiveDT
#     optimal_iterations = 1
#     linear_iteration_ratio = 1
#     dt = 5.0
#   []
# []

[Preconditioning]
  [./smp]
     type = SMP
     full = true
  [../]
[]

[Outputs]
  exodus = true
  file_base = Creep_Strain_Flux_2D_Square_Source_Sink
[]
