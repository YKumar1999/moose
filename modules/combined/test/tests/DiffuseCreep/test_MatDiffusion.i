[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 50
  xmin = 0
  xmax = 10
[]

[Variables]
  [./c]
    [./InitialCondition]
      type = FunctionIC
      function = 'x0:=5.0;thk:=0.5;m:=2;r:=abs(x-x0);v:=exp(-(r/thk)^m);0.1+0.1*v'
    [../]
  [../]
  # [./disp_x]
  # [../]
[]

[AuxVariables]
  [./jx]
    family = MONOMIAL
    order = FIRST
  [../]
  [./jy]
    family = MONOMIAL
    order = FIRST
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

[Kernels]
  [./c]
    type = ADMatDiffusion
    variable = c
    diffusivity = D
  [../]
  [./time]
    type = TimeDerivative
    variable = c
  [../]
  # [./TensorMechanics]
  #   displacements = 'disp_x'
  # [../]
[]

[AuxKernels]
  [./flux_x_1]
    type = DiffusionFluxAux
    component = x
    diffusion_variable = c
    diffusivity = D
    variable = jx
  [../]
  [./flux_x_2]
    type = DiffusionFluxAux
    component = x
    diffusion_variable = c
    diffusivity = D
    variable = jy
  [../]
  [./gb]
    type = FunctionAux
    variable = gb
    function = 'x0:=5.0;thk:=0.5;m:=2;r:=abs(x-x0);v:=exp(-(r/thk)^m);v'
  [../]
  # [./creep_strain_xx]
  #   type = RankTwoAux
  #   variable = creep_strain_xx
  #   rank_two_tensor = creep_strain
  #   index_i = 0
  #   index_j = 0
  # [../]
[]

[Materials]
  [./DiffusivityMat]
    type = ADGenericConstantMaterial
    prop_names = D
    prop_values = 1
  [../]
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
  # [./diffusivity]
  #   type = GBDependentDiffusivity
  #   gb = gb
  #   bulk_parameter = 1
  #   gb_parameter = 1
  #   gb_normal_tensor_name = gb_normal
  #   gb_tensor_prop_name = diffusivity
  # [../]
  # [./diffuse_strain_increment]
  #   type = FluxBasedStrainIncrement
  #   xflux = jx
  #   yflux = jy
  #   gb = gb
  #   property_name = diffuse
  # [../]
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
  # [./creep_strain]
  #   type = SumTensorIncrements
  #   tensor_name = creep_strain
  #   coupled_tensor_increment_names = 'diffuse gb_relax'
  # [../]
  # [./strain]
  #  type = ComputeIncrementalStrain
  #   displacements = 'disp_x'
  # [../]
  # [./stress]
  #   type = ComputeStrainIncrementBasedStress
  #   inelastic_strain_names = creep_strain
  # [../]
  # [./elasticity_tensor]
  #   type = ComputeElasticityTensor
  #   C_ijkl = '120.0 80.0'
  #   fill_method = symmetric_isotropic
  # [../]
[]

[BCs]
  # [./fix_x]
  #   type = DirichletBC
  #   variable = disp_x
  #   boundary = left
  #   value = 0
  # [../]
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

  dt = 1
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
