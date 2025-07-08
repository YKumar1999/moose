sigma = '${fparse 15 * 10^6 * 6.242e-9}' #eV/(nm)^3
delta = '${fparse 4}'
C_sink = '${fparse 0.67}'
R_sink = '${fparse 1e5}'
Va = '${fparse 0.0113843846}' 

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
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
  [v]
  []
  # [eta]
  # []
  [gb]
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
  # [u_IC]
  #   type = BoundingBoxIC
  #   variable = u
  #   x1 = -45
  #   y1 = 45
  #   x2 = -45
  #   y2 = 45
  #   inside = 0
  #   outside = 1
  #   int_width = 15
  # []
  # [./u_IC]
  #   type = IsolatedBoundingBoxIC
  #   variable = u
  #   smaller_coordinate_corners = '-50 -50 0'
  #   larger_coordinate_corners = '50 50 0'
  #   inside = '0'
  #   outside = 1
  #   int_width = 25
  # [../]
  # [./eta_IC]
  #   type = FunctionIC
  #   function = eta_func
  #   variable = eta
  # []
  # [./gb_IC]
  #   type = FunctionIC
  #   function = gb_func
  #   variable = gb
  # []
  [./gbparam]
    type = IsolatedBoundingBoxIC
    variable = gb
    smaller_coordinate_corners = '-50 -50 0'
    larger_coordinate_corners = '50 50 0'
    inside = '0'
    outside = 1
    int_width = 4
  [../]
  [./sourceterm]
    type = IsolatedBoundingBoxIC
    variable = u
    smaller_coordinate_corners = '-70 -50 0'
    larger_coordinate_corners = '70 50 0'
    inside = '0'
    outside = 1
    int_width = 4
  [../]
  [./sinkterm]
    type = IsolatedBoundingBoxIC
    variable = v
    smaller_coordinate_corners = '-50 -70 0'
    larger_coordinate_corners = '50 70 0'
    inside = '0'
    outside = 1
    int_width = 4
  [../]
  [./cv]
    type = ConstantIC
    value = 1e-5
    variable = c_v
  []
[]

# [Functions]
#   [./eta_func]
#     type = ParsedFunction
#     vars = 'x0  width'
#     vals = '${GlobalParams/center}  ${GlobalParams/width}'
#     value = '0.5*(1.0+tanh((x-x0)*2/width))'
#   [../]
#   [gb_func]
#     type = ParsedFunction
#     # expression = 'eta_func:=0.5*(1.0+tanh((x-x0)*2/width)); 16*(eta_func)^2*(1-eta_func)^2' # works
#     # symbol_names = 'x0 width' # works
#     # symbol_values = '${GlobalParams/center}  ${GlobalParams/width}' # works
#     expression = '16*eta_func^2*(1-eta_func)^2'
#     symbol_names = eta_func
#     symbol_values = eta_func
#   []
# []

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
  [./MaskedBodyforce_source]
    type = MaskedBodyForce
    mask = mask
    variable = c_v
    value = 1e-5
  []
  # #Sink term
  [./MaskedBodyforce_sink]
    type = MaskedBodyForce
    mask = mask1
    variable = c_v
    value = -1e-5
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
  [./Periodic]
    [./all]
      variable = c_v
      auto_direction = 'x y'
    [../]
  [../]

  [bottom_y]
    type = DirichletBC
    variable = disp_y
    value = 0
    boundary = bottom
  []
  [left_x]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = left
  []

# #Flux boundary conditions
  [right]
    type = MatNeumannBC
    boundary_material = right_flux
    variable = c_v
    boundary = right
    value = 1
  []
  [left]
    type = MatNeumannBC
    boundary_material = left_flux
    variable = c_v
    boundary = left
    value = 1
  []
  [bottom]
    type = MatNeumannBC
    boundary_material = bottom_flux
    variable = c_v
    boundary = bottom
    value = 1
  []
  [top]
    type = MatNeumannBC
    boundary_material = top_flux
    variable = c_v
    boundary = top
    value = 1
  []

  [Pressure]
    [top]
      boundary = top
      function = '${fparse -1 * ${sigma} }'
    []
  []
[]

[Materials]
  [constants]
    type = GenericConstantMaterial
    prop_names = 'kB T'
    prop_values = '8.6173324e-5 1023'
  []
  #Chemicalpotential
  [./mu_v]
    type = DerivativeParsedMaterial
    expression = '((kB*T)/${Va})*(c_v - 1e-5)'
    material_property_names = 'kB T'
    coupled_variables = c_v
    property_name = mu_v
  []
  #Source
  [./Mask]
    type = ParsedMaterial
    expression = u
    property_name = mask
    coupled_variables = u
    output_properties = 'mask'
    outputs = 'exodus'
  []
  #Sink
  [./Mask1]
    type = ParsedMaterial
    expression = v
    property_name = mask1
    coupled_variables = v
    output_properties = 'mask1'
    outputs = 'exodus'
  []
  [Top]
    type = DerivativeParsedMaterial
    expression = '${R_sink}*(${sigma}-(mu_v/${Va}))*(1e-5*mask/${delta}*${C_sink})'
    material_property_names = 'mu_v mask'
    property_name = top_flux
  []
  [Bottom]
    type = DerivativeParsedMaterial
    expression = '${R_sink}*(${sigma}-(mu_v/${Va}))*(1e-5*mask/${delta}*${C_sink})'
    material_property_names = 'mu_v mask'
    property_name = bottom_flux
  []
  [Right]
    type = DerivativeParsedMaterial
    expression = '${R_sink}*(${sigma}-(mu_v/${Va}))*(-1e-5*mask1/${delta}*${C_sink})'
    material_property_names = 'mu_v mask1'
    property_name = right_flux
  []
  [left]
    type = DerivativeParsedMaterial
    expression = '${R_sink}*(${sigma}-(mu_v/${Va}))*(-1e-5*mask1/${delta}*${C_sink})'
    material_property_names = 'mu_v mask1'
    property_name = left_flux
  []
  [./Lambda]
    type = GenericConstantMaterial
    prop_names = 'Lambda_J'
    prop_values = '0'
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
  #Creep strain increments
  [diffuse_strain_increment]
    type = FluxBasedStrainIncrement
    xflux = jx_v
    yflux = jy_v
    flux_tensor_name = flux_tensor
    flux_total_name = flux_total
    flux_shear_name = flux_shear
    flux_transpose_name = flux_transpose
    flux_deviotoric_LocalC_name = flux_deviotoric_localC
    flux_identity_name = flux_identity
    property_name = diffuse_strain
    Lambda_Prefactor_J = Lambda_J
    flux_trace_name = flux_trace
    output_properties = 'diffuse_strain flux_tensor flux_total flux_shear flux_transpose flux_identity flux_deviotoric_localC flux_trace'
    outputs = 'exodus'
  []
  [diffuse_creep_strain]
    type = SumTensorIncrements
    tensor_name = creep_strain
    coupled_tensor_increment_names = 'diffuse_strain'
    outputs = 'exodus'
  []
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
  file_base = DiffuseGB_SquareGrain_Dimensionalize_New
[]

