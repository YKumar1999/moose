sigma = '${fparse 15 * 10^6 * 6.242e-9}'
# G = 13e3 #nm
# D = ${fparse G / 2}
[Mesh]
  [dist_mesh]
    type = DistributedRectilinearMeshGenerator
    dim = 2
    nx = '${fparse int ( xmax / 1 ) }' #
    ny = '${fparse int ( ymax / 1 ) }' #
    xmin = 0
    xmax = 6.5e3
    ymin = 0
    ymax = 6.5e3
  []
  parallel_type = DISTRIBUTED
[]
[GlobalParams]
  displacements = 'disp_x disp_y'
  derivative_order = 2
  c_v_eq = 1.3563e-09
  # enable_jit = false
  # enable_ad_cache = false
  # extra_vector_tags = 'ref'
[]
[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [mu_v]
  []
  [c_v]
    initial_condition = ${GlobalParams/c_v_eq}
  []

  [c_cr]
    initial_condition = 0.18
  []
  [c_ni]
    initial_condition = 0.08
  []
  [mu_cr]
  []
  [mu_ni]
  []
  [jx_vv]
  []
  [jy_vv]
  []
  [jx_vcr]
  []
  [jy_vcr]
  []
  [jx_vni]
  []
  [jy_vni]
  []
[]

[AuxVariables]
  [sigma_11]
    family = MONOMIAL
  []
  [sigma_22]
    family = MONOMIAL
  []
  [gb]
    family = MONOMIAL
    initial_condition = 0
  []

[]
[BCs]
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
    boundary = 'left'
  []
  [Top_NBC_v]
    type = MatNeumannBC
    variable = c_v
    boundary = top
    boundary_material = 'top_flux_v'
    value = 1
  []
  [Right_NBC_v]
    type = MatNeumannBC
    variable = c_v
    boundary = right
    boundary_material = 'right_flux_v'
    value = 1
  []
  [Top_NBC_cr]
    type = MatNeumannBC
    variable = c_cr
    boundary = top
    boundary_material = 'top_flux_cr'
    value = 1
  []
  [Right_NBC_cr]
    type = MatNeumannBC
    variable = c_cr
    boundary = right
    boundary_material = 'right_flux_cr'
    value = 1
  []
  [Top_NBC_ni]
    type = MatNeumannBC
    variable = c_ni
    boundary = top
    boundary_material = 'top_flux_ni'
    value = 1
  []
  [Right_NBC_ni]
    type = MatNeumannBC
    variable = c_ni
    boundary = right
    boundary_material = 'right_flux_ni'
    value = 1
  []
  [Pressure]
    [top]
      boundary = top
      function = '${fparse -1 * ${sigma} }'
    []
  []
[]

[Kernels]
  [TensorMechanics]
    displacements = 'disp_x disp_y'
    strain = SMALL
    incremental = true
  []
  #Vacancy diff
  #Vacancy diffusion
  [dc_v_dt]
    type = TimeDerivative
    variable = c_v
  []
  [chempot_v]
    type = CHSplitChemicalPotential
    variable = mu_v
    chemical_potential_prop = mu_v_prop
    c = c_v
  []
  [flux_v_v]
    type = MatDiffusion
    variable = c_v
    v = mu_v
    diffusivity = M_v_v
  []
  [flux_v_cr]
    type = MatDiffusion
    variable = c_v
    v = mu_cr
    diffusivity = M_v_cr
  []
  [flux_v_ni]
    type = MatDiffusion
    variable = c_v
    v = mu_ni
    diffusivity = M_v_ni
  []

  #Cr diffusion
  [dc_cr_dt]
    type = TimeDerivative
    variable = c_cr
  []
  [chempot_cr]
    type = CHSplitChemicalPotential
    variable = mu_cr
    chemical_potential_prop = mu_cr_prop
    c = c_cr
  []
  [flux_cr_v]
    type = MatDiffusion
    variable = c_cr
    v = mu_v
    diffusivity = M_cr_v
  []
  [flux_cr_cr]
    type = MatDiffusion
    variable = c_cr
    v = mu_cr
    diffusivity = M_cr_cr
  []
  [flux_cr_ni]
    type = MatDiffusion
    variable = c_cr
    v = mu_ni
    diffusivity = M_cr_ni
  []

  #Ni diffusion
  [dc_ni_dt]
    type = TimeDerivative
    variable = c_ni
  []
  [chempot_ni]
    type = CHSplitChemicalPotential
    variable = mu_ni
    chemical_potential_prop = mu_ni_prop
    c = c_ni
  []
  [flux_ni_v]
    type = MatDiffusion
    variable = c_ni
    v = mu_v
    diffusivity = M_ni_v
  []
  [flux_ni_cr]
    type = MatDiffusion
    variable = c_ni
    v = mu_cr
    diffusivity = M_ni_cr
  []
  [flux_ni_ni]
    type = MatDiffusion
    variable = c_ni
    v = mu_ni
    diffusivity = M_ni_ni
  []

  # #Vacancy fluxes
  [jx_vv_val]
    type = DiffusionFluxComponent
    variable = jx_vv
    v = mu_v
    M = M_v_v
    c = c_v
    component = '0'
  []
  [jy_vv_val]
    type = DiffusionFluxComponent
    variable = jy_vv
    v = mu_v
    M = M_v_v
    c = c_v
    component = '1'
  []

  [jx_vcr_val]
    type = DiffusionFluxComponent
    variable = jx_vcr
    v = mu_cr
    M = M_v_cr
    c = c_v
    component = '0'
  []
  [jy_vcr_val]
    type = DiffusionFluxComponent
    variable = jy_vcr
    v = mu_cr
    M = M_v_cr
    c = c_v
    component = '1'
  []

  [jx_vni_val]
    type = DiffusionFluxComponent
    variable = jx_vni
    v = mu_v
    M = M_v_ni
    c = c_v
    component = '0'
  []
  [jy_vni_val]
    type = DiffusionFluxComponent
    variable = jy_vni
    v = mu_ni
    M = M_v_ni
    c = c_v
    component = '1'
  []
[]
[AuxKernels]
  [matl_s11]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
    variable = sigma_11
  []
  [matl_s22]
    type = RankTwoAux
    rank_two_tensor = stress
    index_i = 1
    index_j = 1
    variable = sigma_22
  []
[]
[Materials]
  [constants]
    type = GenericConstantMaterial
    prop_names = 'kB           T      c0_ni  c0_cr  ratio_sink_to_mobility lambda_0 V_a f0 a_304L'
    prop_values = '8.6173324e-5 1023   0.08    0.18  3e-4 1e-2 0.0113843846 0.78145 0.3571'
  []
  [elasticity] # This is for Ni
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = '${fparse 165 * 10^9 * 6.242e-9}'
    poissons_ratio = 0.27
  []
  [f_alloy] # Taylor FE
    type = DerivativeParsedMaterial
    property_name = f_alloy
    coupled_variables = 'c_cr c_ni'
    material_property_names = 'c0_ni c0_cr'
    constant_names = 'f0         mu0_ni     mu0_cr      theta0_nini      theta0_crcr        theta0_nicr   '
    constant_expressions = '-0.4944   -0.2707    0.02844      1.233            0.6355             0.1246        ' # eV 
    expression = 'f0 + mu0_ni*(c_ni-c0_ni) + mu0_cr*(c_cr-c0_cr) + 0.5*theta0_nini*(c_ni-c0_ni)^2 + 0.5*theta0_crcr*(c_cr-c0_cr)^2 + theta0_nicr*(c_ni-c0_ni)*(c_cr-c0_cr)'
  []
  [f_defect]
    type = DerivativeParsedMaterial
    property_name = f_defect
    coupled_variables = 'c_v mu_v'
    material_property_names = 'kB T'
    expression = 'kB*T*(c_v*log(c_v/${GlobalParams/c_v_eq}) + (1-c_v)*log(1-c_v) )' # eV
  []
  [mu_v_prop]
    type = DerivativeParsedMaterial
    material_property_names = 'f_defect(c_v) V_a df_dc_v:=D[f_defect,c_v] lambda_0 kB T'
    property_name = mu_v_prop
    coupled_variables = 'c_v mu_v sigma_11 sigma_22 disp_x disp_y'
    expression = 'df_dc_v + lambda_0*V_a*(${sigma})/3' # eV ## 
    output_properties = 'mu_v_prop'
    outputs = 'exodus'
  []
  [mu_cr_prop]
    type = DerivativeParsedMaterial
    material_property_names = 'f_alloy(c_ni,c_cr) df_dc_cr:=D[f_alloy,c_cr]'
    property_name = mu_cr_prop
    coupled_variables = 'c_cr c_ni c_v'
    expression = 'df_dc_cr'
  []
  [mu_ni_prop]
    type = DerivativeParsedMaterial
    material_property_names = 'f_alloy(c_ni,c_cr) df_dc_ni:=D[f_alloy,c_ni]'
    property_name = mu_ni_prop
    coupled_variables = 'c_cr c_ni c_v'
    expression = 'df_dc_ni'
  []
  #Vacancy diff
  [M_v_v]
    type = DerivativeParsedMaterial
    property_name = M_v_v
    coupled_variables = 'c_v mu_v'
    material_property_names = 'kB T'
    expression = '(1.794e+8*c_v)/kB/T' # nm^2/(eV.K.s)
    outputs = nemesis
  []
  [M_v_cr]
    type = DerivativeParsedMaterial
    property_name = M_v_cr
    coupled_variables = 'c_v'
    material_property_names = 'kB T'
    expression = '-(1.543e+7*c_v)/kB/T' # nm^2/(eV.K.s)
  []
  [M_v_ni]
    type = DerivativeParsedMaterial
    property_name = M_v_ni
    coupled_variables = 'c_v'
    material_property_names = 'kB T'
    expression = '(6.903e+6*c_v)/kB/T' # nm^2/(eV.K.s)
  []
  # Cr diff
  [M_cr_cr]
    type = DerivativeParsedMaterial
    property_name = M_cr_cr
    coupled_variables = 'c_v'
    material_property_names = 'kB T'
    expression = '(3.147e+7*c_v)/kB/T' # nm^2/(eV.K.s)
  []
  [M_cr_v]
    type = DerivativeParsedMaterial
    property_name = M_cr_v
    coupled_variables = 'c_v'
    material_property_names = 'kB T'
    expression = '-(4.772e+7*c_v)/kB/T' # nm^2/(eV.K.s)
  []
  [M_cr_ni]
    type = DerivativeParsedMaterial
    property_name = M_cr_ni
    coupled_variables = 'c_v'
    material_property_names = 'kB T'
    expression = '-(3.384e+6*c_v)/kB/T' # nm^2/(eV.K.s)
  []
  # Ni diff
  [M_ni_ni]
    type = DerivativeParsedMaterial
    property_name = M_ni_ni
    coupled_variables = 'c_v'
    material_property_names = 'kB T'
    expression = '(5.29e+6*c_v)/kB/T' # nm^2/(eV.K.s)
  []
  [M_ni_v]
    type = DerivativeParsedMaterial
    property_name = M_ni_v
    coupled_variables = 'c_v'
    material_property_names = 'kB T'
    expression = '-(7.446e+6*c_v)/kB/T' # nm^2/(eV.K.s)
  []
  [M_ni_cr]
    type = DerivativeParsedMaterial
    property_name = M_ni_cr
    coupled_variables = 'c_v'
    material_property_names = 'kB T'
    expression = '-(9.073e+5*c_v)/kB/T' # nm^2/(eV.K.s)
  []

  [R_sink]
    type = DerivativeParsedMaterial
    property_name = 'R_sink'
    coupled_variables = 'c_v mu_v sigma_11 sigma_22'
    material_property_names = 'a_304L kB T M_v_v f0'
    constant_names = 'C_I C_D G'
    constant_expressions = '1 1 ${fparse ( 165 * 10^9 * 6.242e-9 ) / ( 2 * (1+0.27) ) }'
    expression = '(C_I*C_D*f0*M_v_v*a_304L*(${sigma})^2/(6*sqrt(2)*G^2))'
    outputs = nemesis
  []
  [top_flux_v]
    type = DerivativeParsedMaterial
    property_name = top_flux_v
    coupled_variables = 'c_cr c_v c_ni mu_v sigma_11 sigma_22'
    material_property_names = 'V_a R_sink'
    expression = 'R_sink*(${sigma}-mu_v/V_a)*(1-c_v)'
    outputs = nemesis
  []
  [right_flux_v]
    type = DerivativeParsedMaterial
    property_name = right_flux_v
    coupled_variables = 'c_cr c_v c_ni mu_v sigma_11 sigma_22'
    material_property_names = 'V_a R_sink'
    expression = 'R_sink*(0-mu_v/V_a)*(1-c_v)'
    outputs = nemesis
  []
  [top_flux_cr]
    type = DerivativeParsedMaterial
    property_name = top_flux_cr
    coupled_variables = 'c_cr c_v c_ni mu_v sigma_11 sigma_22'
    material_property_names = 'V_a R_sink'
    expression = 'R_sink*(${sigma}-mu_v/V_a)*(-c_cr)'
    outputs = nemesis
  []
  [right_flux_cr]
    type = DerivativeParsedMaterial
    property_name = right_flux_cr
    coupled_variables = 'c_cr c_v c_ni mu_v sigma_11 sigma_22'
    material_property_names = 'V_a R_sink'
    expression = 'R_sink*(0-mu_v/V_a)*(-c_cr)'
    outputs = nemesis
  []
  [top_flux_ni]
    type = DerivativeParsedMaterial
    property_name = top_flux_ni
    coupled_variables = 'c_cr c_v c_ni mu_v sigma_11 sigma_22'
    material_property_names = 'V_a R_sink'
    expression = 'R_sink*(${sigma}-mu_v/V_a)*(-c_ni)'
    outputs = nemesis
  []
  [right_flux_ni]
    type = DerivativeParsedMaterial
    property_name = right_flux_ni
    coupled_variables = 'c_cr c_v c_ni mu_v sigma_11 sigma_22'
    material_property_names = 'V_a R_sink'
    expression = 'R_sink*(0-mu_v/V_a)*(-c_ni)'
    outputs = nemesis
  []
  [eigenstrain_prefactor]
    type = DerivativeParsedMaterial
    property_name = 'eigenstrain_prefactor'
    material_property_names = 'lambda_0'
    coupled_variables = 'c_v'
    expression = 'lambda_0*(c_v - ${GlobalParams/c_v_eq} )'
  []
  [eigenstrain]
    type = ComputeVolumetricEigenstrain
    eigenstrain_name = eigenstrain
    volumetric_materials = 'eigenstrain_prefactor'
    args = c_v
  []
  [strain]
    type = ComputeIncrementalSmallStrain
    displacements = 'disp_x disp_y'
    eigenstrain_names = eigenstrain
  []
  #Creep strain increments
  [diffuse_strain_increment_v]
    type = FluxBasedStrainIncrement
    xflux = jx_vv
    yflux = jy_vv
    gb = gb
    property_name = diffuse_v
  []
  [diffuse_strain_increment_ni]
    type = FluxBasedStrainIncrement
    xflux = jx_vni
    yflux = jy_vni
    gb = gb
    property_name = diffuse_ni
  []
  [diffuse_strain_increment_cr]
    type = FluxBasedStrainIncrement
    xflux = jx_vcr
    yflux = jy_vcr
    gb = gb
    property_name = diffuse_cr
  []
  [diffuse_creep_strain]
    type = SumTensorIncrements
    tensor_name = creep_strain
    coupled_tensor_increment_names = 'diffuse_v diffuse_cr diffuse_ni'
  []
  [stress]
    type = ComputeStrainIncrementBasedStress
    inelastic_strain_names = creep_strain
  []
[]
[Postprocessors]
  [top_flux]
    type = SideAverageMaterialProperty
    boundary = top
    property = 'top_flux_v'
  []
  [right_flux]
    type = SideAverageMaterialProperty
    boundary = right
    property = 'right_flux_v'
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]
# [Problem]
#   type = ReferenceResidualProblem
#   extra_tag_vectors = 'ref'
#   reference_vector = 'ref'
#   group_variables = 'c_v c_ni c_cr; mu_v mu_cr mu_ni; disp_x disp_y'
# []
[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       ilu           2'
  # petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  # petsc_options_value = 'lu superlu_dist'
  l_tol = 1e-3
  l_max_its = 100
  nl_abs_tol = 1e-9
  automatic_scaling = true
  scaling_group_variables = 'c_v c_ni c_cr; mu_v mu_ni mu_cr; disp_x disp_y'
  compute_scaling_once = false
  end_time = 864000
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-8
    iteration_window = 2
    optimal_iterations = 9
    growth_factor = 1.25
    cutback_factor = 0.8
  []
[]
[Debug]
  show_var_residual_norms = true
[]
[Outputs]
  execute_on = 'INITIAL TIMESTEP_END'
  nemesis = true
  csv = true
  # interval = 5
  checkpoint = true
[]
