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
  params.addCoupledVar("TimederivativeConc", "Derivative of Concentration");
  params.addRequiredParam<MaterialPropertyName>("property_name",
                                                "Name of diffusive strain increment property");
  params.addRequiredParam<MaterialPropertyName>("flux_tensor_name","Name of flux tensor value");
  params.addRequiredParam<MaterialPropertyName>("flux_total_name","Name of flux total");
  params.addRequiredParam<MaterialPropertyName>("flux_transpose_name","Name of flux transpose");
  params.addRequiredParam<MaterialPropertyName>("flux_shear_name","Name of shear value");
  params.addRequiredParam<MaterialPropertyName>("flux_deviotoric_LocalC_name","Name of flux_deviotoricLocalC value");
  params.addRequiredParam<MaterialPropertyName>("flux_identity_name","Name of identity tensor");
  params.addRequiredParam<MaterialPropertyName>("flux_DerivativeConc","Name of Derivative Concentration");
  params.addRequiredParam<MaterialPropertyName>("Lambda_Prefactor","Value of prefactor");
  params.addRequiredParam<MaterialPropertyName>("Source","Value of Source");
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
    _derivative_conc(coupledValue("TimederivativeConc")),
    _strain_increment(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("property_name"))),
    _flux_tensor(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("flux_tensor_name"))),
    _flux_shear(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("flux_shear_name"))),
    _flux_total(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("flux_total_name"))),
    _flux_deviotoric_localC(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("flux_deviotoric_LocalC_name"))),
    _flux_transpose(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("flux_transpose_name"))),
    _flux_identity(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("flux_identity_name"))),
    _flux_derivativeconc(
        declareProperty<RankTwoTensor>(getParam<MaterialPropertyName>("flux_DerivativeConc"))),
    _Lambda_prefactor(getMaterialProperty<Real>("Lambda_Prefactor")),
    _source(getMaterialProperty<Real>("Source"))


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
  computeIdentityTensor();

  _strain_increment[_qp] = -0.5 * (_flux_grad_tensor + _flux_grad_tensor.transpose()) - 0.5 * ((_derivative_conc[_qp] - _source[_qp]) * _Identity_tensor) + ((_Lambda_prefactor[_qp])*_derivative_conc[_qp]*_Identity_tensor); 
  _strain_increment[_qp] *= _dt;
  //Storing the tensor value
  _flux_tensor[_qp] = _flux_grad_tensor; 
  _flux_shear[_qp] = 0.5 * (_flux_grad_tensor + _flux_grad_tensor.transpose()) - 0.5 * (_derivative_conc[_qp] * _Identity_tensor);
  _flux_total[_qp] = 0.5 * (_flux_grad_tensor + _flux_grad_tensor.transpose());
  _flux_deviotoric_localC[_qp] = -0.5 * (_flux_grad_tensor + _flux_grad_tensor.transpose()) + 0.5 * (_derivative_conc[_qp] * _Identity_tensor) + ((_Lambda_prefactor[_qp])*_derivative_conc[_qp]*_Identity_tensor); 
  _flux_transpose[_qp] = 0.5 * _flux_grad_tensor.transpose();
  _flux_identity[_qp] = _Identity_tensor;
  _flux_derivativeconc[_qp] = (_derivative_conc[_qp])*_Identity_tensor;
}

void
FluxBasedStrainIncrement::computeFluxGradTensor()
{
  _flux_grad_tensor.zero();

  _flux_grad_tensor.fillRow(0, (*_grad_jx)[_qp]);

  if (_has_yflux)
    _flux_grad_tensor.fillRow(1, (*_grad_jy)[_qp]);

  if (_has_zflux)
    _flux_grad_tensor.fillRow(2, (*_grad_jz)[_qp]);
}

void
FluxBasedStrainIncrement::computeIdentityTensor()
{
  RankTwoTensor iden(RankTwoTensor::initIdentity);
  _Identity_tensor.zero();

  _Identity_tensor(0,0) = iden(0,0);

  if (_has_yflux)
  {
    _Identity_tensor(0,1) = iden(0,1);
    _Identity_tensor(1,0) = iden(1,0);
    _Identity_tensor(1,1) = iden(1,1);
  }

  if (_has_zflux)
  {
    _Identity_tensor(0,2) = iden(0,2);
    _Identity_tensor(2,0) = iden(2,0);
    _Identity_tensor(2,2) = iden(2,2);
  }
}
