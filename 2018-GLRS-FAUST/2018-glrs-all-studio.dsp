//--------------------------------------------------------------------------------------------------
// 2018 - GIUSEPPE SILVI - GRAZIA. LUCI E RABBIA. SPAZIO.
//--------------------------------------------------------------------------------------------------

declare name "GRAZIE. LUCI E RABBIA. SPAZIO.";
declare version "0.1";
declare author "Giuseppe Silvi";
declare copyright "Giuseppe Silvi 2018";
declare license "BSD";
declare reference "giuseppesilvi.com";
declare description "AMBIENTE ESECUTIVO";

ma = library("maths.lib");
ba = library("basics.lib");
de = library("delays.lib");
// si = library("signals.lib");
// an = library("analyzers.lib");
fi = library("filters.lib");
// os = library("oscillators.lib");
// no = library("noises.lib");
// ef = library("misceffects.lib");
co = library("compressors.lib");
// ve = library("vaeffects.lib");
// pf = library("phaflangers.lib");
// re = library("reverbs.lib");
// en = library("envelopes.lib");

ac = library("acoustics.lib");

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
// ================================================= GUI =
// =======================================================



// =======================================================
// ========================================= DEFINITIONS =
// =======================================================

vmeter(x)	= attach(x, envelop(x) : vbargraph("[unit:dB]", -70, 0));
hmeter(x)	= attach(x, envelop(x) : hbargraph("[unit:dB]", -70, 0));

envelop = abs : max(ba.db2linear(-70)) : ba.linear2db : min(10)  : max ~ -(80.0/ma.SR);

mt2samp = *(343.00/ma.SR);

in_gain = vslider("[1] Gain [unit:dB] [style:knob]", -20, -96, 12, 0.1) : ba.db2linear;

delbank = delays
  with{
    at1 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch1", 1., 0., 1000., 0.1))) ;
    at2 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch2", 2., 0., 1000., 0.1))) ;
    at3 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch3", 3., 0., 1000., 0.1))) ;
    at4 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch4", 4., 0., 1000., 0.1))) ;
    at5 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch5", 5., 0., 1000., 0.1))) ;
    at6 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch6", 6., 0., 1000., 0.1))) ;

    delays = at1,at2,at3,at4,at5,at6;
};

// =======================================================
// =============================================== FLUTE =
// =======================================================

flute_out = fl_at
  with{
    fl_at = _ <: vgroup("[0] Flute Delays", delbank);
};

// =======================================================
// =============================================== DBASS =
// =======================================================

dbass_out = db_at
  with{
    db_at = _ <: vgroup("[1] Double Bass Delays", delbank);
};

// =======================================================
// ================================================ BSAX =
// =======================================================

bsax_out = bs_at
  with{
    bs_at = _ <:  vgroup("[2] Bari Sax Delays", delbank);
};

// =======================================================
// ========================================== COMPRESSOR =
// =======================================================

gs_m_comp = ba.bypass1(cbp,gs_mono_compressor)
with{
	  comp_group(x) = hgroup("[1] COMPRESSOR", x);
  	meter_group(x) = comp_group(vgroup("[0]", x));
	  kctl_group(x) = comp_group(vgroup("[1]", x));

  cbp = meter_group(checkbox("[0] Bypass [tooltip: When this is checked the compressor has no effect]"));

  gainview = co.compression_gain_mono(ratio,threshold,attack,release) : ba.linear2db :
	           meter_group(vbargraph("[1] Compressor Gain [unit:dB] [tooltip: Current gain of the compressor in dB]",-50,+10));

	displaygain = _ <: _, abs : _, gainview : attach;

	gs_mono_compressor = displaygain(co.compressor_mono(ratio,threshold,attack,release)) : *(makeupgain);

	ctl_group(x) = kctl_group(vgroup("[3] Compression Control", x));
    ratio = ctl_group(vslider("[0] Ratio [style:knob]", 5, 1, 20, 0.1));
	  threshold = ctl_group(vslider("[1] Threshold [unit:dB] [style:knob]", -30, -100, 10, 0.1));
	  attack = ctl_group(vslider("[2] Attack [unit:ms] [style:knob] [scale:log] ", 50, 1, 1000, 0.1)) : *(0.001) : max(1/ma.SR);
	  release = ctl_group(vslider("[3] Release [unit:ms] [style: knob] [scale:log]", 500, 1, 1000, 0.1)) : *(0.001) : max(1/ma.SR);

  makeupgain = comp_group(vslider("[5] Makeup Gain [unit:dB]", 40, -96, 96, 0.1)) : ba.db2linear;
};

// =======================================================
// ===================================== INPUT SELECTION =
// =======================================================

input_selector = _,_,_,_,_,_,_,_,_,_,_,_ : !,!,!,!,!,!,!,!,_,_,_,! ;

// =======================================================
// ============================================= OUTPUTS =
// =======================================================

output_metering = hgroup("[3] outputs metering", vmeter, vmeter, vmeter, vmeter, vmeter, vmeter);

flute = hgroup("[0] Flute", _,_,_ : ba.selectn(3,0) : gs_m_comp : vmeter <: flute_out);
dbass = hgroup("[1] Double Bass", _,_,_ : ba.selectn(3,1) : gs_m_comp : vmeter <: dbass_out);
 bsax = hgroup("[2] Bari Sax", _,_,_ : ba.selectn(3,2) : gs_m_comp : vmeter <: bsax_out);

process = input_selector <: hgroup("", vgroup("", flute, dbass, bsax) :> output_metering);
