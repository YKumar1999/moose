#This is the model, where there is no GB Dependency in flux calculations and GBDependentDiffusivity
#To test effect of vacancy flux on creep strain. 
#Removed Volumetric component from total strain

[GlobalParams]
  center = 5
  width = 1
[]

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
  [./mu]
  []
  [./jx]
  [../]
  [./disp_x]
  [../]
[]

[AuxVariables]
  [./eta]
  [../]
  [./gb]
    family = LAGRANGE
    order  = FIRST
  [../]
  [./creep_strain_xx]
    family = MONOMIAL
    order  = CONSTANT
  [../]
[]

[ICs]
  [./eta]
    type = FunctionIC
    function = eta_func
    variable = eta
  [../]
  [./gb]
    type = FunctionIC
    function = gb_func
    variable = gb
  [../]
  [./Cv]
    type = FunctionIC
    function = Cv_func
    variable = Cv
  [../]
[]

[Functions]
  [./eta_func]
    type = ParsedFunction
    expression = '0.5*(1.0+tanh((x-x0)*2/width))'
    symbol_names = 'x0 width'
    symbol_values = '${GlobalParams/center}  ${GlobalParams/width}'
  []
  [gb_func]
    type = ParsedFunction
    # expression = 'eta_func:=0.5*(1.0+tanh((x-x0)*2/width)); 16*(eta_func)^2*(1-eta_func)^2' # works
    # symbol_names = 'x0 width' # works
    # symbol_values = '${GlobalParams/center}  ${GlobalParams/width}' # works
    expression = '16*eta_func^2*(1-eta_func)^2'
    symbol_names = eta_func
    symbol_values = eta_func
  []
  [Cv_func]
    type = ParsedFunction
    expression = 'cVgb_ic * 16.0 * eta_func^2*(1-eta_func)^2'
    symbol_names = 'cVgb_ic eta_func' 
    symbol_values = '1e-6 eta_func' 
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
  [./chempot]
    type = CHSplitChemicalPotential
    variable = mu
    chemical_potential_prop = mu_prop
    c = Cv
  [../]
  [./TensorMechanics]
    displacements = 'disp_x'
  [../]
[]

[AuxKernels]
  [./gb]
    type = FunctionAux
    variable = gb
    function = gb_func
  [../]
  [./creep_strain_xx]
    type = RankTwoAux
    variable = creep_strain_xx
    rank_two_tensor = creep_strain
    index_i = 0
    index_j = 0
  [../]
[]

[Materials]
  [./chemical_potential]
    type = DerivativeParsedMaterial
    block = 0
    property_name = mu_prop
    coupled_variables = Cv
    expression = 'Cv-0.2'
    derivative_order = 1
  [../]
  [./DiffusivityMat]
    type = ADGenericConstantMaterial
    prop_names = D
    prop_values = 1
  [../]
  # [./Mobilityprop]
  #   type = GenericConstantMaterial
  #   prop_names = Dtensor
  #   prop_values = '1'
  # []
  # [./phase_normal]
  #   type = PhaseNormalTensor
  #   phase = gb
  #   normal_tensor_name = gb_normal
  # [../]
  # [./aniso_tensor]
  #   type = GBDependentAnisotropicTensor
  #   gb = gb
  #   bulk_parameter = 1 
  #   gb_parameter = 1
  #   gb_normal_tensor_name = gb_normal
  #   gb_tensor_prop_name = aniso_tensor
  # [../]
  [./diffusivity]
    type = GBDependentDiffusivity
    # gb = gb
    bulk_parameter = 1
    # gb_parameter = 1
    # gb_normal_tensor_name = gb_normal
    gb_tensor_prop_name = Dtensor
  [../]
  [./diffuse_strain_increment]
    type = FluxBasedStrainIncrement
    xflux = jx
    # yflux = jy
    #gb = gb
    property_name = diffuse_strain
    output_properties = diffuse_strain_00
    outputs = 'exodus'
  [../]
  # [./gb_relax_prefactor]
  #   type = DerivativeParsedMaterial
  #   block = 0
  #   expression = '0.01*(c-0.15)*gb'
  #   coupled_variables = 'c gb'
  #   property_name = gb_relax_prefactor
  #   derivative_order = 1
  # [../]
  # [./gb_relax]
  #   type = GBRelaxationStrainIncrement
  #   property_name = gb_relax
  #   prefactor_name = gb_relax_prefactor
  #   gb_normal_name = gb_normal
  # [../]
  [./creep_strain]
    type = SumTensorIncrements
    tensor_name = creep_strain
    coupled_tensor_increment_names = 'diffuse_strain' #gb_relax'
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

[BCs]
  [./fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  [../]
[]

[Executioner]
  type = Transient
  solve_type = PJFNK

  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       lu           1'

  nl_rel_tol = 1e-10
  nl_max_its = 5

  l_tol = 1e-4
  l_max_its = 20
  end_time = 1e8

  dt = 0.001
  # num_steps = 100
[]

[Preconditioning]
  [./smp]
     type = SMP
     full = true
  [../]
[]

[Outputs]
  exodus = true
  file_base = Strain_Flux_1D_GB_WithoutSource_Hydrostatic
[]
