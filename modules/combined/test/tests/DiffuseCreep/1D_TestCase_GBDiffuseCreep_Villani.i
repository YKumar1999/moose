#TestCase for 1D Grain Boundary Diffuse Creep for Single Grain
# Implementation from Villani, et al 2015 Model for Diffuse Creep: https://iopscience.iop.org/article/10.1088/0965-0393/23/5/055006 

[GlobalParams]
  displacements = 'disp_x'
[]

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 50
  xmin = 0
  xmax = 10
[]

[Variables]
  [./Cv]
    [./InitialCondition]
      type = FunctionIC
      function = 'x0:=5.0;thk:=0.5;m:=2;r:=abs(x-x0);v:=exp(-(r/thk)^m);0.1+0.1*v'
    [../]
  [../]
  [./mu]
  [../]
  [./jx_1]
  [../]
  [./jx_2]
  [../]
[]

[Physics]
  [SolidMechanics]
    [QuasiStatic]
      [all]
        strain = SMALL 
        generate_output = 'strain_xx'
        add_variables = true
      [../]
    []
  []
[]

[BCs]
  [./disp_x_right]
    type = DirichletBC
    boundary = right
    value = 0
    variable = disp_x
  [../]
  [./disp_x_left]
    type = DirichletBC
    boundary = left
    value = 0
    variable = disp_x
  [../]
  [./Cv_in]
    type = DirichletBC
    boundary = left
    value = 0.1
    variable = Cv
  [../]
  [./Cv_out]
    type = DirichletBC
    boundary = right
    value = 0.5
    variable = Cv
  [../]
  [./flux_1_in]
    type = DirichletBC
    boundary = left
    value = 0.1
    variable = jx_1
  [../]
  [./flux_2_out]
    type = DirichletBC
    boundary = right
    value = 0.5
    variable = jx_2
  [../]
[]

[AuxVariables]
  [./gb]
    family = LAGRANGE
    order  = FIRST
  [../]
[]

[Kernels]
  [./conc]
    type = CHSplitConcentration
    variable = Cv
    mobility = mobility_prop
    chemical_potential_var = mu
  [../]
  [./chempot]
    type = CHSplitChemicalPotential
    variable = mu
    chemical_potential_prop = mu_prop
    c = Cv
  [../]
  [./flux_x_1]
    type = CHSplitFlux
    variable = jx_1
    component = 0
    mobility_name = mobility_prop
    mu = mu
    c = Cv
  [../]
  [./flux_x_2]
    type = CHSplitFlux
    variable = jx_2
    component = 0
    mobility_name = mobility_prop
    mu = mu
    c = Cv
  [../]
  [./time]
    type = TimeDerivative
    variable = Cv
  [../]
[]

[AuxKernels]
  [./gb]
    type = FunctionAux
    variable = gb
    function = 'x0:=5.0;thk:=0.5;m:=2;r:=abs(x-x0);v:=exp(-(r/thk)^m);v'
  [../]
[]

[Materials]
  #Stress Calculations
  # [./elasticity_tensor]
  #   type = ComputeIsotropicElasticityTensor
  #   youngs_modulus = 2.1e5
  #   poissons_ratio = 0.3
  # [../]
  # [./stress]
  #   type = ComputeLinearElasticStress
  # [../]
  
  [./chemical_potential]
    type = DerivativeParsedMaterial
    block = 0
    property_name = mu_prop
    coupled_variables = Cv
    expression = 'Cv'
    derivative_order = 1
  [../]
  [./var_dependence]
    type = DerivativeParsedMaterial
    block = 0
    expression = 'Cv*(1.0-Cv)'
    coupled_variables = Cv
    property_name = var_dep
    derivative_order = 1
  [../]
  [./mobility]
    type = CompositeMobilityTensor
    block = 0
    M_name = mobility_prop
    tensors = diffusivity
    weights = var_dep
    args = Cv
  [../]
  [./phase_normal]
    type = PhaseNormalTensor
    phase = gb
    normal_tensor_name = gb_normal
  [../]
  [./aniso_tensor]
    type = GBDependentAnisotropicTensor
    gb = gb
    bulk_parameter = 0.1
    gb_parameter = 1
    gb_normal_tensor_name = gb_normal
    gb_tensor_prop_name = aniso_tensor
  [../]
  [./diffusivity]
    type = GBDependentDiffusivity
    gb = gb
    bulk_parameter = 0.1
    gb_parameter = 1
    gb_normal_tensor_name = gb_normal
    gb_tensor_prop_name = diffusivity
  [../]

  #Total strain rate
  [./diffuse_strain_increment]
    type = FluxBasedStrainIncrement
    xflux = jx_1
    yflux = jx_2
    gb = gb
    property_name = Totalstrainrate
  [../]

  #GB Relaxation Creep Term
  [./gb_relax_prefactor]
    type = DerivativeParsedMaterial
    block = 0
    expression = '0.01*(Cv-0.15)*gb'
    coupled_variables = 'Cv gb'
    property_name = gb_relax_prefactor
    derivative_order = 1
  [../]
  [./gb_relax]
    type = GBRelaxationStrainIncrement
    property_name = gb_relax
    prefactor_name = gb_relax_prefactor
    gb_normal_name = gb_normal
  [../]
  
  #Total strain rate (Including volume expansion and GB mechanism)
  [./Totalstrainrate]
    type = SumTensorIncrements
    tensor_name = Totalstrainrate
    coupled_tensor_increment_names = gb_relax
  [../]
[]

[Executioner]
  type = Transient
  solve_type = PJFNK

  petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
  petsc_options_value = 'asm      31                  preonly       lu           1'

  nl_max_its = 5
  dt = 20
  num_steps = 5
[]

[Preconditioning]
  [./smp]
     type = SMP
     full = true
  [../]
[]

[Outputs]
  exodus = true
[]
