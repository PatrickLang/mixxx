/***************************************************************************
                          controlpotmeter.cpp  -  description
                             -------------------
    begin                : Wed Feb 20 2002
    copyright            : (C) 2002 by Tue and Ken Haste Andersen
    email                : 
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include "controlpotmeter.h"

/* -------- ------------------------------------------------------
   Purpose: Creates a new potmeter
   Input:   n - name
            midino - number of the midi controller.
            master - pointer to the control to which the potmeter is
                     attached. This control is acknowledged when the
                     potmeter is changed.
            midicontroller - pointer to the midi controller.
   -------- ------------------------------------------------------ */
ControlPotmeter::ControlPotmeter()
{
}

ControlPotmeter::ControlPotmeter(ConfigObject::ConfigKey *key, FLOAT_TYPE _minvalue, FLOAT_TYPE _maxvalue) : ControlObject(key)
{
  position = middlePosition;
  minvalue = _minvalue;
  maxvalue = _maxvalue;
  valuerange = maxvalue-minvalue;
  value = minvalue + 0.5*(maxvalue-minvalue);
}

ControlPotmeter::~ControlPotmeter()
{
}

/* -------- ------------------------------------------------------
   Purpose: Set the position of the potmeter, and change the
            value correspondingly.
   Input:   The (new) position.
   Output:  The value is updated.
   -------- ------------------------------------------------------ */
#define min(a,b)            (((a) < (b)) ? (a) : (b))
void ControlPotmeter::slotSetPosition(int _newpos)
{
  char newpos =(char)_newpos;
    qDebug("got %i",newpos);

  // Ensure that the position is within bounds:
  position = max(minPosition, min(newpos, maxPosition));
  // Calculate the value linearly:
  value = (valuerange/positionrange)*(newpos-minPosition)+minvalue;
  //qDebug("Controlpotmeter: changed %s to %g.",name,value);

  emit valueChanged(value);
}

char ControlPotmeter::getPosition()
{
  return position;
}

void ControlPotmeter::setValue(FLOAT_TYPE newvalue)
{
  value = newvalue;
  emit valueChanged(value);
}

FLOAT_TYPE ControlPotmeter::getValue()
{
  return value;
}
