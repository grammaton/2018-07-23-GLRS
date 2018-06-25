//--------------------------------------------------------------------------------------------------
// 2018 - GIUSEPPE SILVI - GRAZIE. LUCI E RABBIA. SPAZIO.
//--------------------------------------------------------------------------------------------------

declare name "GRAZIE. LUCI E RABBIA. SPAZIO.";
declare version "0.2";
declare author "Giuseppe Silvi";
declare copyright "Giuseppe Silvi 2018";
declare license "BSD";
declare reference "giuseppesilvi.com";
declare description "AMBIENTE ESECUTIVO";

import("stdfaust.lib");

// =======================================================
// ========================================== STAGE PLAN =
// =======================================================

//---1---6---2---
//--fl--dbs--bs--
//---------------
//-----regia-----
//---------------
//---4---5---3---

// =======================================================
// ========================================= DEFINITIONS =
// =======================================================

  vmeter(x)	= attach(x, envelop(x) : vbargraph("[unit:dB]", -70, 0));
  hmeter(x)	= attach(x, envelop(x) : hbargraph("[unit:dB]", -70, 0));
    envelop = abs : max(ba.db2linear(-70)) : ba.linear2db : min(10)  : max ~ -(80.0/ma.SR);
    mt2samp = *(343.00/ma.SR); // into acoustics.lib - ac.mt2samp

// =======================================================
// ========================================== COMPRESSOR =
// =======================================================
// ===== custom version of faust compressor_demo =========
// =======================================================

gs_m_comp = ba.bypass1(cbp,gs_mono_comp)
with{
	  comp_group(x) = vgroup("[1] Compressor", x);
   meter_group(x) = comp_group(vgroup("[3]", x));
	  kctl_group(x) = comp_group(hgroup("[1]", x));

  cbp = meter_group(checkbox("[0] Bypass [tooltip: When this is checked the compressor has no effect]"));

  gainview = co.compression_gain_mono(ratio,threshold,attack,release) : ba.linear2db :
	           meter_group(hbargraph("[1] Compressor Gain [unit:dB] [tooltip: Current gain of the compressor in dB]",-50,+10));

	displaygain = _ <: _, abs : _, gainview : attach;

	gs_mono_comp = displaygain(co.compressor_mono(ratio,threshold,attack,release)) : *(makeupgain) ;

	ctl_group(x) = kctl_group(hgroup("[2] Compression Control", x));
         ratio = ctl_group(vslider("[0] Ratio [style:knob]", 5, 1, 20, 0.1));
	   threshold = ctl_group(vslider("[1] Threshold [unit:dB] [style:knob]", -30, -100, 10, 0.1));
	      attack = ctl_group(vslider("[2] Attack [unit:ms] [style:knob] [scale:log] ", 50, 1, 1000, 0.1)) : *(0.001) : max(1/ma.SR);
	     release = ctl_group(vslider("[3] Release [unit:ms] [style: knob] [scale:log]", 500, 1, 1000, 0.1)) : *(0.001) : max(1/ma.SR);

    makeupgain = comp_group(hslider("[5] Makeup Gain [unit:dB]", 0, -96, 96, 0.1)) : ba.db2linear;
};

// =======================================================
// ===================================== INPUT SELECTION =
// =======================================================
// === TO DO: ============================================
// ===== - graphical input selection =====================
// ===== - separate tab for input selection ==============
// =======================================================

input_selector = _,_,_,_,_,_,_,_,_,_,_,_ : !,!,!,!,!,!,!,!,_,_,_,! ;

// =======================================================
// ============================================= OUTPUTS =
// =======================================================
// === TO DO: ============================================
// ===== - attenuation by distance =======================
// =======================================================

delbank = delays
  with{
    at1 = de.sdelay(192000,1024,mt2samp(nentry("ch1 distance [unit:meters]", 1., 0., 1000., 0.1))) ;
    at2 = de.sdelay(192000,1024,mt2samp(nentry("ch2 distance [unit:meters]", 2., 0., 1000., 0.1))) ;
    at3 = de.sdelay(192000,1024,mt2samp(nentry("ch3 distance [unit:meters]", 3., 0., 1000., 0.1))) ;
    at4 = de.sdelay(192000,1024,mt2samp(nentry("ch4 distance [unit:meters]", 4., 0., 1000., 0.1))) ;
    at5 = de.sdelay(192000,1024,mt2samp(nentry("ch5 distance [unit:meters]", 5., 0., 1000., 0.1))) ;
    at6 = de.sdelay(192000,1024,mt2samp(nentry("ch6 distance [unit:meters]", 6., 0., 1000., 0.1))) ;

    delays = at1,at2,at3,at4,at5,at6;
};

flute_out = _ <: vgroup("[2] Flute Delays", delbank);

dbass_out = _ <: vgroup("[2] Double Bass Delays", delbank);

basax_out = _ <:  vgroup("[2] Bari Sax Delays", delbank);

output_metering = vgroup("[3] Outputs", hmeter, hmeter, hmeter, hmeter, hmeter, hmeter);

//flute = vgroup("[0] FLUTE",       _,_,_ : ba.selectn(3,0) : vgroup("", gs_m_comp : hmeter) <: flute_out);
flute = vgroup("[0] FLUTE",       _,_,_ : ba.selectn(3,0) : vgroup("", gs_m_comp : hmeter) <: flute_out);
dbass = vgroup("[1] DOUBLE BASS", _,_,_ : ba.selectn(3,1) : vgroup("", gs_m_comp : hmeter) <: dbass_out);
basax = vgroup("[2] BARI SAX",    _,_,_ : ba.selectn(3,2) : vgroup("", gs_m_comp : hmeter) <: basax_out);

process = input_selector <: vgroup("", hgroup("", flute, dbass, basax) :> output_metering);
