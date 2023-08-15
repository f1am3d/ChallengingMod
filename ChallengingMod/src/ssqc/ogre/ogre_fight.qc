void() OgreGrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 40, world);
	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

void() OgreGrenadeTouch =
{
	if (other == self.owner)
		// don't explode on owner
		return;
	if (other.takedamage == DAMAGE_AIM)
	{
		OgreGrenadeExplode();
		return;
	}
	// bounce sound
	sound (self, CHAN_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};


/*
================
OgreFireGrenade
================
*/
void() OgreFireGrenade =
{
	local entity missile;

	self.effects = self.effects | EF_MUZZLEFLASH;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;

	// set missile speed
	makevectors (self.angles);

	CalculateGrenadeTrajectory(missile);

	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = OgreGrenadeTouch;

	// set missile duration
	missile.nextthink = time + 1.5;
	missile.think = OgreGrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin);
};

/*
===========
OgreCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() OgreCheckAttack = {
	local vector spot1, spot2;
	local entity targ;
	local float chance;

	if (enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	if (time < self.attack_finished)
		return FALSE;

	if (!enemy_vis)
		return FALSE;

	targ = self.enemy;

	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater)
		// sight line crossed contents
		return FALSE;

	if (trace_ent != targ)
	{
		// don't have a clear shot
		return FALSE;
	}

	// missile attack
	if (time < self.attack_finished)
		return FALSE;

	if (enemy_range == RANGE_FAR) chance = 0.1;
	else if (enemy_range == RANGE_MID) chance = 0.75;
	else if (enemy_range == RANGE_NEAR) chance = 0.9;
	else chance = 0;

	self.attack_state = AS_MISSILE;
	SUB_AttackFinished (1 + 2 * random());

	return TRUE;
};

void()	OgreJumpTouch = {
	if (self.health <= 0) return;

	if (!checkbottom(self))	{
		if (self.flags & FL_ONGROUND) {
			// jump randomly to not get hung up
			self.touch = SUB_Null;
			// self.think = demon1_jump1;
			self.nextthink = time + 0.1;
		}

		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.nextthink = time + 0.1;
};

void() OrgreCheckJump = {
	local float distance = vlen(self.enemy.origin - self.origin);

	if( /*random() < 0.75 || */distance > 250 ) return;

	local vector toEnemy = normalize(self.enemy.origin - self.origin);
	
	self.touch = OgreJumpTouch;
	makevectors (self.angles);

	// lift a bit to prevent stuck on stairs
	self.origin_z += 20;

	self.velocity = toEnemy * 400 + '0 0 240';
	self.th_melee();

	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};