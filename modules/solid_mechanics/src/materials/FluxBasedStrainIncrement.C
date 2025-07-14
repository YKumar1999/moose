//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "FluxBasedStrainIncrement.h"
#include "libmesh/quadrature.h"

registerMooseObject("SolidMechanicsApp", FluxBasedStrainIncrement);

InputParameters
FluxBasedStrainIncrement::validParams()
{
  InputParameters params = Material::validParams();
  params.addClassDescription("Compute strain increment based on flux");
  params.addRequiredCoupledVar("xflux", "x or 0-direction component of flux");
  params.addCoupledVar("yflux", "y or 1-direction component of flux");
  params.addCoupledVar("zflux", "z or 2-direction component of flux");
  params.addCoupledVar("gb", "Grain boundary order parameter");
  params.addRequiredParam<MaterialPropertyName>("property_name",
                                                "Name of diffusive strain increment property");
  params.addRequiredParam<MaterialPropertyName>("flux_tensor_name","Name of flux tensor value");
  params.addRequiredParam<MaterialPropertyName>("flux_total_name","Name of flux total");
  params.addRequiredParam<MaterialPropertyName>("flux_transpose_name","Name of flux transpose");

  return params;
}

FluxBasedStrainIncrement::FluxBasedStrainIncrement(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _grad_jx(&coupledGradient("xflux")),
    _has_yflux(isCoupled("yflux")),
    _has_zflux(isCoupled("zflux")),
    _grad_jy(_has_yflux ? &coupledGradient("yflux") : nullptr),
    _grad_jz(_has_zflux ? &coupledGradient("zflux") : nullptr),
    _gb(isCoupled("gb") ? coupledValue("gb") : _zero),
    _strain_increment(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("property_name"))),
    _flux_tensor(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("flux_tensor_name"))),
    _flux_total(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("flux_total_name"))),
    _flux_transpose(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("flux_transpose_name")))


{
}

void
FluxBasedStrainIncrement::initQpStatefulProperties()
{
  _strain_increment[_qp].zero();
}

void
FluxBasedStrainIncrement::computeQpProperties()
{
  computeFluxGradTensor();

  _strain_increment[_qp] = -0.5 * (_flux_grad_tensor + _flux_grad_tensor.transpose());
  _strain_increment[_qp] *= _dt;
  //Storing the tensor value
  _flux_tensor[_qp] = _flux_grad_tensor;
  _flux_total[_qp] = 0.5 * (_flux_grad_tensor + _flux_grad_tensor.transpose());
  _flux_transpose[_qp] = 0.5 * _flux_grad_tensor.transpose();

}

void
FluxBasedStrainIncrement::computeFluxGradTensor()
{
  _flux_grad_tensor.zero();

  // _flux_grad_tensor.fillRow(00, (*_grad_jx)[_qp]); //Testing Flux Based Accumulation  

  if (_has_yflux)
    // _flux_grad_tensor.fillRow(11, (*_grad_jy)[_qp]); //Testing Flux Based Accumulation
    _flux_grad_tensor(0,1) = (*_grad_jx)[_qp](1);

    _flux_grad_tensor(1,0) = (*_grad_jy)[_qp](0);

  if (_has_zflux)
    _flux_grad_tensor(0,2) = (*_grad_jx)[_qp](2);
    _flux_grad_tensor(1,2) = (*_grad_jy)[_qp](2);

    _flux_grad_tensor(2,0) = (*_grad_jz)[_qp](0);
    _flux_grad_tensor(2,1) = (*_grad_jz)[_qp](1);
    // _flux_grad_tensor.fillRow(22, (*_grad_jz)[_qp]); //Testing Flux Based Accumulation
}
