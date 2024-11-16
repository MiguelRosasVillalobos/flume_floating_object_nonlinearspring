/*---------------------------------------------------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     |
    \\  /    A nd           | www.openfoam.com
     \\/     M anipulation  |
-------------------------------------------------------------------------------
    Copyright (C) 2011-2016 OpenFOAM Foundation
-------------------------------------------------------------------------------
License
    This file is part of OpenFOAM.

    OpenFOAM is free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    OpenFOAM is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
    for more details.

    You should have received a copy of the GNU General Public License
    along with OpenFOAM.  If not, see <http://www.gnu.org/licenses/>.

\*---------------------------------------------------------------------------*/

#include "nonlinearSpring.H"
#include "addToRunTimeSelectionTable.H"
#include "sixDoFRigidBodyMotion.H"

// * * * * * * * * * * * * * * Static Data Members * * * * * * * * * * * * * //

namespace Foam
{
namespace sixDoFRigidBodyMotionRestraints
{
    defineTypeNameAndDebug(nonlinearSpring, 0);

    addToRunTimeSelectionTable
    (
        sixDoFRigidBodyMotionRestraint,
        nonlinearSpring,
        dictionary
    );
}
}


// * * * * * * * * * * * * * * * * Constructors  * * * * * * * * * * * * * * //

Foam::sixDoFRigidBodyMotionRestraints::nonlinearSpring::nonlinearSpring
(
    const word& name,
    const dictionary& sDoFRBMRDict
)
:
    sixDoFRigidBodyMotionRestraint(name, sDoFRBMRDict),
    anchor_(),
    refAttachmentPt_(),
    stiffness_(),
    lhz_(),
    restLength_()
{
    read(sDoFRBMRDict);
}


// * * * * * * * * * * * * * * * * Destructor  * * * * * * * * * * * * * * * //

Foam::sixDoFRigidBodyMotionRestraints::nonlinearSpring::~nonlinearSpring()
{}


// * * * * * * * * * * * * * * Member Functions  * * * * * * * * * * * * * * //

void Foam::sixDoFRigidBodyMotionRestraints::nonlinearSpring::restrain
(
    const sixDoFRigidBodyMotion& motion,
    vector& restraintPosition,
    vector& restraintForce,
    vector& restraintMoment
) const
{
    restraintPosition = motion.transform(refAttachmentPt_);

    vector r = restraintPosition - anchor_;

    scalar magR = mag(r);
    r /= (magR + VSMALL);

    vector v = motion.velocity(restraintPosition);

    restraintForce = 2*stiffness_*(1-(restLength_ /(sqrt(pow(magR, 2) + pow(lhz_, 2)) )))*(magR - restLength_)*r;

    restraintMoment = Zero;

    if (motion.report())
    {
        Info<< " attachmentPt - anchor " << r*magR
            << " spring length " << magR
            << " force " << restraintForce
            << endl;
    }
}


bool Foam::sixDoFRigidBodyMotionRestraints::nonlinearSpring::read
(
    const dictionary& sDoFRBMRDict
)
{
    sixDoFRigidBodyMotionRestraint::read(sDoFRBMRDict);

    sDoFRBMRCoeffs_.readEntry("anchor", anchor_);
    sDoFRBMRCoeffs_.readEntry("refAttachmentPt", refAttachmentPt_);
    sDoFRBMRCoeffs_.readEntry("stiffness", stiffness_);
    sDoFRBMRCoeffs_.readEntry("lhz", lhz_);
    sDoFRBMRCoeffs_.readEntry("restLength", restLength_);

    return true;
}


void Foam::sixDoFRigidBodyMotionRestraints::nonlinearSpring::write
(
    Ostream& os
) const
{
    os.writeEntry("anchor", anchor_);
    os.writeEntry("refAttachmentPt", refAttachmentPt_);
    os.writeEntry("stiffness", stiffness_);
    os.writeEntry("lhz", lhz_);
    os.writeEntry("restLength", restLength_);
}

// ************************************************************************* //
