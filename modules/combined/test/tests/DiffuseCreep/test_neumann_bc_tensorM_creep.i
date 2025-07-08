[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = '${fparse int ( 2 * xmax / ${GlobalParams/int_width} ) }'
  ny = '${fparse int ( 2 * ymax / ${GlobalParams/int_width} ) }'
  xmin = 0
  xmax = 50
  ymin = 0
  ymax = 50
  uniform_refine = 0
  skip_partitioning = true
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  derivative_order = 2
  int_width = 4
  c_v_eq = 1.3563e-09
[]

[Variables]
  [mu]
  []
  [c_v]
    initial_condition = ${GlobalParams/c_v_eq}
  []
  [jx]
  []
  [jy]
  []
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [s11_aux]
    order = CONSTANT
    family = MONOMIAL
  []
  [s12_aux]
    order = CONSTANT
    family = MONOMIAL
  []
  [s22_aux]
    order = CONSTANT
    family = MONOMIAL
  []
  [s33_aux]
    order = CONSTANT
    family = MONOMIAL
  []
  [s0_aux]
    order = CONSTANT
    family = MONOMIAL
  []
  [eta]
  []
  [eta1]
  []
  [gb]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[ICs]
  [eta_grain]
    type = BoundingBoxIC
    variable = eta
    x1 = -${Mesh/xmax}
    x2 = ${Mesh/xmax}
    y1 = -${Mesh/ymax}
    y2 = ${Mesh/ymax}
    inside = 1
    outside = 0
  []
  [eta1_grain]
    type = BoundingBoxIC
    variable = eta1
    x1 = -${Mesh/xmax}
    x2 = ${Mesh/xmax}
    y1 = -${Mesh/ymax}
    y2 = ${Mesh/ymax}
    inside = 0
    outside = 1
  []
[]

[BCs]
  [bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []
  [left_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []

  [sink_top_y]
    type = MatNeumannBC
    variable = c_v
    boundary = 'top'
    value = 1
    boundary_material = neumann_sink_top_y
  []
  [sink_right_x]
    type = MatNeumannBC
    variable = c_v
    boundary = 'right'
    value = 1
    boundary_material = neumann_sink_right_x
  []

[]

[Kernels]
  #Tensor mechanics
  [TensorMechanics]
    displacements = 'disp_x disp_y'
  []

  #Vacancy diffusion
  [dc_dt]
    type = TimeDerivative
    variable = c_v
  []

  [conc]
    type = CHSplitConcentration
    variable = c_v
    mobility = M_v
    chemical_potential_var = mu
  []

  [chempot]
    type = CHSplitChemicalPotential
    variable = mu
    chemical_potential_prop = mu_prop
    c = c_v
  []

  [flux_x]
    type = CHSplitFlux
    variable = jx
    component = '0'
    mobility_name = M_v
    mu = mu
    c = c_v
  []
  [flux_y]
    type = CHSplitFlux
    variable = jy
    component = '1'
    mobility_name = M_v
    mu = mu
    c = c_v
  []
[]

[AuxKernels]
  [gb_val]
    type = MaterialRealAux
    variable = gb
    property = gb_mat
  []

  [matl_s11]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
    variable = s11_aux
  []
  [matl_s12]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 0
    index_j = 1
    variable = s12_aux
  []
  [matl_s22]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 1
    index_j = 1
    variable = s22_aux
  []
  [matl_s33]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 2
    index_j = 2
    variable = s33_aux
  []
  [matl_s0]
    type = ParsedAux
    variable = s0_aux
    coupled_variables = 's11_aux s22_aux s33_aux'
    expression = 's11_aux+s22_aux+s33_aux'
  []
[]

[Materials]
  [constants]
    type = GenericConstantMaterial 
    prop_names = 'kB T V_a R '
    prop_values = '8.6173324e-5 1073 0.01099207207 8.314462618 '
  []
  [gb_mat]
    type = DerivativeParsedMaterial
    coupled_variables = eta
    property_name = 'gb_mat'
    expression = '16*eta^2*(1-eta)^2'
  []

  [s11_mat]
    type = ParsedMaterial
    coupled_variables = 's11_aux'
    property_name = s11_mat
    expression = 's11_aux'
  []
  [s12_mat]
    type = ParsedMaterial
    coupled_variables = 's12_aux'
    property_name = s12_mat
    expression = 's12_aux'
  []
  [s22_mat]
    type = ParsedMaterial
    coupled_variables = 's22_aux'
    property_name = s22_mat
    expression = 's22_aux'
  []

  [neumann_sink_top_y] # +ve for entering
    type = ParsedMaterial
    expression = '1.5e-5' 
    property_name = neumann_sink_top_y
    outputs = exodus
  []
  [neumann_sink_right_x]
    type = ParsedMaterial
    expression = '-1.5e-5' 
    property_name = neumann_sink_right_x
    outputs = exodus
  []

  [f_v]
    type = DerivativeParsedMaterial
    material_property_names = 'kB T V_a'
    property_name = f_v
    coupled_variables = 'c_v mu s11_aux s22_aux'
    expression = 'kB*T*(c_v*log(c_v/${GlobalParams/c_v_eq}) + (1-c_v)*log(1-c_v) )'
  []
  [mu_prop] # no mech coupling!
    type = DerivativeParsedMaterial
    material_property_names = 'f_v(c_v) V_a df_dc:=D[f_v,c_v]'
    property_name = mu_prop
    coupled_variables = 'c_v mu s11_aux s22_aux'
    expression = 'df_dc'
  []

  [c_v_norm]
    type = DerivativeParsedMaterial
    property_name = c_v_norm
    coupled_variables = 'c_v'
    expression = 'c_v/${GlobalParams/c_v_eq}'
    output_properties = 'c_v_norm'
    outputs = exodus
  []

  [var_dependence]
    type = DerivativeParsedMaterial
    block = 0
    material_property_names = 'kB T'
    expression = 'c_v*(1.0-c_v)/kB/T'
    coupled_variables = c_v
    property_name = chi_v
    derivative_order = 1
  []
  [M_v]
    type = CompositeMobilityTensor
    M_name = M_v
    tensors = diffusivity
    weights = chi_v
    coupled_variables = 'c_v mu'
  []
  [D_func]
    type = ParsedMaterial
    property_name = D
    material_property_names = 'R T gb_mat'
    expression = '3.657e+8/f0' #nm^2/s
    constant_names = 'f0'
    constant_expressions = '0.7814'
    outputs = exodus
  []
  [diffusivity]
    type = IsotropicDiffusionTensor
    diffusion_coefficient = D
    diffusivity_tensor_name = diffusivity
  []
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = '${fparse 207 * 10^9 * 6.242e-9}'
    poissons_ratio = 0.3
  []

  #Creep strain increments
  [diffuse_strain_increment]
    type = FluxBasedStrainIncrement
    xflux = jx
    yflux = jy
    gb = gb
    property_name = diffuse
  []
  [diffuse_creep_strain]
    type = SumTensorIncrements
    tensor_name = creep_strain
    coupled_tensor_increment_names = 'diffuse'
  []

  [strain]
    type = ComputeIncrementalSmallStrain
    displacements = 'disp_x disp_y'
    # eigenstrain_names = eigenstrain
  []

  [stress]
    type = ComputeStrainIncrementBasedStress
    inelastic_strain_names = creep_strain
  []
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

# [Debug]
#   show_var_residual_norms = true
# []

[Postprocessors]
  [total_cv]
    type = ElementIntegralVariablePostprocessor
    variable = c_v
  []
  [force_y]
    type = SideIntegralVariablePostprocessor
    variable = 's22_aux'
    boundary = top
  []
  [dy]
    type = SideAverageValue
    variable = 'disp_y'
    boundary = 'top'
    execute_on = 'INITIAL NONLINEAR TIMESTEP_END'
  []
  [creep_dy]
    type = ChangeOverTimePostprocessor
    postprocessor = 'dy'
    # change_with_respect_to_initial = true
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
  checkpoint = true
[]
