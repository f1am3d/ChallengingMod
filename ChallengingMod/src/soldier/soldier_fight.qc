void() army_fire = {
	local vector dir;
	local entity enemt;

	ai_face();	

	// fire somewhat behind the player, so a dodging player is harder to hit
	enemt = self.enemy;

	dir = enemt.origin - enemt.velocity * 0.1;
	dir = normalize (dir - self.origin);

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "soldier/sattck1.wav", 1, ATTN_NORM);

	FireBullets (16, dir, '0.2 0.2 0');
};


/*
===========
SoldierCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() SoldierCheckAttack = {
	local vector spot1, spot2;
	local entity targ;
	local float chance;

	targ = self.enemy;

	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_inopen && trace_inwater) return FALSE;			// sight line crossed contents

	if (trace_ent != targ) return FALSE;	// don't have a clear shot


	// missile attack
	if (time < self.attack_finished) return FALSE;

	if (enemy_range == RANGE_FAR) return FALSE;

	if (enemy_range == RANGE_MELEE) chance = 1;
	else if (enemy_range == RANGE_NEAR) chance = 0.8;
	else if (enemy_range == RANGE_MID) chance = 0.5;
	else if (enemy_range == RANGE_FAR) chance = 0.1;
	else chance = 0;

	if (random() < chance) {
		SUB_AttackFinished (1 + random());

		if (random() < 0.3) self.lefty = !self.lefty;

		return TRUE;
	}

	return FALSE;
};

void () SoldierAttack = {
	self.th_missile ();
	army_fire();
};