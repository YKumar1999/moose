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
  [jx_v]
  []
  [jy_v]
  []
  [c_v]
  []
  [disp_x]
  []
  [disp_y]
  []
[]

#Test
[AuxVariables]
  [u]
  []
  [./Timederivative_cv]
    order = CONSTANT
    family = MONOMIAL
  []
  [grad_jx_x]
    order = FIRST
    family = MONOMIAL
  []
  [grad_jx_y]
    order = FIRST
    family = MONOMIAL
  []
  [grad_jy_y]
    order = FIRST
    family = MONOMIAL
  []
  [grad_jy_x]
    order = FIRST
    family = MONOMIAL
  []
[]

[ICs]
  [./cv]
    type = ConstantIC
    value = 1e-6
    variable = c_v
  []
  [./MaskingCondition]
    type = SmoothCircleIC
    invalue = 1
    outvalue = 0
    radius = 25
    variable = u
    x1 = 0
    y1 = 0
  [../]
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
  #Source term
  [./MaskedBodyforce]
    type = MaskedBodyForce
    mask = mask
    variable = c_v
    value = 1e-5
  []
  [./flux_x]
    type = GradientComponent #Only solves expression J = -DgradU (where D = 1)
    v = c_v
    variable = jx_v
    component = 0
    diffusivity_name = D_nonAD
  [../]
  [./flux_y]
    type = GradientComponent #Only solves expression J = -DgradU (where D = 1)
    v = c_v
    variable = jy_v
    component = 1
    diffusivity_name = D_nonAD
  [../]
  #Tensor mechanics
  [TensorMechanics]
    displacements = 'disp_x disp_y'
  []
[]

#Test
[AuxKernels]
  [Timederivative_cv]
    type = TimeDerivativeAux
    variable = Timederivative_cv
    functor = c_v
  []
  [flux_x_x]
    type = VariableGradientComponent
    gradient_variable = jx_v
    variable = grad_jx_x
    component = 'x'
  []
  [flux_x_y]
    type = VariableGradientComponent
    gradient_variable = jx_v
    variable = grad_jx_y
    component = 'y'
  []
  [flux_y_y]
    type = VariableGradientComponent
    gradient_variable = jy_v
    variable = grad_jy_y
    component = 'y'
  []
  [flux_y_x]
    type = VariableGradientComponent
    gradient_variable = jy_v
    variable = grad_jy_x
    component = 'x'
  []
[]


[BCs]
  # [left_x]
  #   type = DirichletBC
  #   variable = disp_x
  #   boundary = left
  #   value = 0
  # []
  # [Top_x]
  #   type = DirichletBC
  #   variable = disp_y
  #   boundary = bottom
  #   value = 0
  # []
  # [source_top_y]
  #   type = MatNeumannBC
  #   variable = c_v
  #   boundary = 'top'
  #   value = 1
  #   boundary_material = neumann_source_top_y
  # []
  # [source_right_x]
  #   type = MatNeumannBC
  #   variable = c_v
  #   boundary = 'right'
  #   value = 1
  #   boundary_material = neumann_source_right_x
  # []
  # [source_bottom_y]
  #   type = MatNeumannBC
  #   variable = c_v
  #   boundary = 'bottom'
  #   value = 1
  #   boundary_material = neumann_source_bottom_y
  # []
  # [source_left_x]
  #   type = MatNeumannBC
  #   variable = c_v
  #   boundary = 'left'
  #   value = 1
  #   boundary_material = neumann_source_left_x
  # []
[]

[Materials]
  [./Lambda]
    type = GenericConstantMaterial
    prop_names = Lambda
    prop_values = 1
  []
  [./Mask]
    type = ParsedMaterial
    expression = if(u>0,1,0)
    property_name = mask
    coupled_variables = u
    output_properties = 'mask'
    outputs = 'exodus'
  []
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
  # [neumann_source_top_y] # +ve for entering
  #   type = ParsedMaterial
  #   expression = '1.5e-5' 
  #   property_name = neumann_source_top_y
  #   outputs = exodus
  # []
  # [neumann_source_right_x]
  #   type = ParsedMaterial
  #   expression = '-1.5e-5' #Sign Change 
  #   property_name = neumann_source_right_x
  #   outputs = exodus
  # []
  # [neumann_source_bottom_y] # +ve for entering
  #   type = ParsedMaterial
  #   expression = '1.5e-5' 
  #   property_name = neumann_source_bottom_y
  #   outputs = exodus
  # []
  # [neumann_source_left_x]
  #   type = ParsedMaterial
  #   expression = '-1.5e-5' #Sign Change 
  #   property_name = neumann_source_left_x
  #   outputs = exodus
  # []
  #Creep strain increments
  [diffuse_strain_increment]
    type = FluxBasedStrainIncrement
    xflux = jx_v
    yflux = jy_v
    TimederivativeConc = Timederivative_cv
    flux_tensor_name = flux_tensor
    flux_total_name = flux_total
    flux_shear_name = flux_shear
    flux_DerivativeConc = flux_derivativeconc
    flux_transpose_name = flux_transpose
    flux_trace_name = flux_trace
    flux_volume_name = flux_volum
    flux_identity_name = flux_identity
    property_name = diffuse_strain
    Lambda_Prefactor = Lambda
    output_properties = 'diffuse_strain flux_tensor flux_total flux_shear flux_volum flux_trace flux_transpose flux_identity flux_derivativeconc'
    outputs = 'exodus'
  []
  [diffuse_creep_strain]
    type = SumTensorIncrements
    tensor_name = creep_strain
    coupled_tensor_increment_names = 'diffuse_strain'
    outputs = 'exodus'
  []
  #Mobility Test
  # [M_v]
  #   type = DerivativeParsedMaterial
  #   property_name = M_v
  #   coupled_variables = 'c_v'
  #   expression = 'c_v*(1-c_v)' # nm^2/(eV.K.s)
  # []
  [./strain]
    type = ComputeIncrementalStrain
    displacements = 'disp_x disp_y'
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

# [Executioner]
#   type = Transient
#   scheme = bdf2
#   solve_type = NEWTON
#   petsc_options_iname = '-pc_type'
#   petsc_options_value = 'lu'
#   # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
#   # petsc_options_value = 'lu superlu_dist'
#   # petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
#   # petsc_options_value = 'hypre    boomeramg      31                 0.7'
#   # petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
#   # petsc_options_value = 'asm      31                  preonly       lu           2'
#   l_tol = 1e-4 #1e-3
#   l_max_its = 100
#   nl_abs_tol = 1e-9
#   end_time = 1e5
#   dt = 0.1

#   # [Adaptivity]
#   #   max_h_level = 2
#   #   refine_fraction = 0.3
#   #   coarsen_fraction = 0.2
#   # []

#   [TimeStepper]
#     type = IterationAdaptiveDT
#     dt = 1e-6
#     iteration_window = 2
#     optimal_iterations = 9
#     growth_factor = 1.25
#     cutback_factor = 0.8
#   []
#   dtmax = 1e5
#   # end_time = 100
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
  l_max_its = 5 # SK
  nl_max_its = 5 # SK
  nl_abs_tol = 1e-8
  nl_rel_tol = 1e-08 # SK
  end_time = 1e5
  dt = 0.1

  line_search = 'none' # SK
  automatic_scaling = false # SK
  nl_forced_its = 2 # SK

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
  file_base = 2D_Scalar_Square_Bodyforce_withcorrection_NonUniform_Lambda1_RemovedBC
[]
