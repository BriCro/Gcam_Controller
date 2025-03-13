// GCam 2.0 Addon Config.cpp

#include "gcam_component.hpp"


class CfgPatches
{
	class gcam
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {};
	};
};

class CfgVehicles
{
	class Land;
	class Man : Land
	{
		class UserActions
		{
			class gcam_launch
			{
				displayName="GCam";
				position="pos driver";
				onlyforplayer=1;
				radius=10.0;
				condition="this == player";
				statement="[] execVM ""gcam\gcam_controller.sqf""";
			};
		};
	};
	class All {};
	class Static: All {};
	class Building: Static {};
	class NonStrategic: Building {};
	class TargetTraining: NonStrategic {};
	class TargetGrenade: TargetTraining {};
};
