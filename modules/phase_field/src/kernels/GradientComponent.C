//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "GradientComponent.h"

registerMooseObject("PhaseFieldApp", GradientComponent);

InputParameters
GradientComponent::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addClassDescription(
      "Set the kernel variable to a specified component of the gradient of a coupled variable.");
  params.addRequiredCoupledVar("v", "Coupled variable to match gradient component of");
  params.addRequiredParam<unsigned int>("component",
                                        "Component of the gradient of the coupled variable v");
  params.addRequiredParam<MaterialPropertyName>("diffusivity_name",
                                        "Diffusivity of the species"); //Added the diffusivity term
  return params;
}

GradientComponent::GradientComponent(const InputParameters & parameters)
  : Kernel(parameters),
    _v_var(coupled("v")),
    _grad_v(coupledGradient("v")),
    _component(getParam<unsigned int>("component")),
    _diffusion_coef(getMaterialProperty<Real>("diffusivity_name"))
{
  if (_component >= LIBMESH_DIM)
    paramError("component", "Component too large for LIBMESH_DIM");
}

Real
GradientComponent::computeQpResidual()
{
  return (_u[_qp] + (_diffusion_coef)[_qp] * _grad_v[_qp](_component)) * _test[_i][_qp]; //J + D*gradU = 0
} 

Real
GradientComponent::computeQpJacobian()
{
  return _phi[_j][_qp] * _test[_i][_qp];
}

Real
GradientComponent::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _v_var)
  return (_diffusion_coef)[_qp] * _grad_phi[_j][_qp](_component) * _test[_i][_qp]; // + _grad_phi instead of negative
  return 0.0;
}
