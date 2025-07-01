//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "GBDependentDiffusivity.h"

registerMooseObject("PhaseFieldApp", GBDependentDiffusivity);

InputParameters
GBDependentDiffusivity::validParams()
{
  InputParameters params = Material::validParams();
  params.addParam<Real>("bulk_parameter", 0.0, "Parameter value of bulk material");
  params.addParam<MaterialPropertyName>("gb_tensor_prop_name", "Name of GB tensor property");
  params.addClassDescription("Compute diffusivity rank two tensor based on GB phase variable");
  return params;
}

GBDependentDiffusivity::GBDependentDiffusivity(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
      _bulk_parameter(getParam<Real>("bulk_parameter")),
          _gb_dependent_tensor(
        declareProperty<RealTensorValue>(getParam<MaterialPropertyName>("gb_tensor_prop_name")))
{
}

void
GBDependentDiffusivity::initQpStatefulProperties()
{
  _gb_dependent_tensor[_qp].zero();
}

void
GBDependentDiffusivity::computeQpProperties()
{
  RankTwoTensor iden(RankTwoTensor::initIdentity);
  RankTwoTensor gb_tensor;

  gb_tensor = _bulk_parameter * iden;
  gb_tensor.fillRealTensor(_gb_dependent_tensor[_qp]);
}
