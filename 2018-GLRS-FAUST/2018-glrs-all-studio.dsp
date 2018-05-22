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
// =============================================== FLUTE =
// =======================================================

//flute_group(x) = vgroup(" ---- BASS FLUTE ----", x);
fat_group(x) = hgroup("AMP-TRASP", x);

dly_group(x) = hgroup("", x);
met_group(x) = vgroup("", x);

// =======================================================
// ============================================= PROGRAM =
// =======================================================

flute_out = fl_sixch
  with{
    at1 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch1", 1., 0., 1000., 0.1))) ;
    at2 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch2", 2., 0., 1000., 0.1))) ;
    at3 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch3", 3., 0., 1000., 0.1))) ;
    at4 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch4", 4., 0., 1000., 0.1))) ;
    at5 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch5", 5., 0., 1000., 0.1))) ;
    at6 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch6", 6., 0., 1000., 0.1))) ;

    fl_sixch = flute_group(vgroup("[2] OUTPUTS", _ <:
    hgroup("[0]", at1,at2,at3,at4,at5,at6) : hmeter, hmeter, hmeter, hmeter, hmeter, hmeter));
};

dbass_out = fl_sixch
  with{
    at1 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch1", 1., 0., 1000., 0.1))) ;
    at2 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch2", 2., 0., 1000., 0.1))) ;
    at3 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch3", 3., 0., 1000., 0.1))) ;
    at4 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch4", 4., 0., 1000., 0.1))) ;
    at5 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch5", 5., 0., 1000., 0.1))) ;
    at6 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch6", 6., 0., 1000., 0.1))) ;

    fl_sixch = flute_group(vgroup("[2] OUTPUTS", _ <:
    hgroup("[0]", at1,at2,at3,at4,at5,at6) : hmeter, hmeter, hmeter, hmeter, hmeter, hmeter));
};

bsax_out = fl_sixch
  with{
    at1 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch1", 1., 0., 1000., 0.1))) ;
    at2 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch2", 2., 0., 1000., 0.1))) ;
    at3 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch3", 3., 0., 1000., 0.1))) ;
    at4 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch4", 4., 0., 1000., 0.1))) ;
    at5 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch5", 5., 0., 1000., 0.1))) ;
    at6 = de.sdelay(192000,1024,ac.mt2samp(nentry("distance ch6", 6., 0., 1000., 0.1))) ;

    fl_sixch = flute_group(vgroup("[2] OUTPUTS", _ <:
    hgroup("[0]", at1,at2,at3,at4,at5,at6) : hmeter, hmeter, hmeter, hmeter, hmeter, hmeter));
};

gs_m_comp = ba.bypass1(cbp,gs_mono_compressor)
with{
	comp_group(x) = flute_group(vgroup("[1] COMPRESSOR", x));
  	meter_group(x) = comp_group(hgroup("[0]", x));
	  kctl_group(x) = comp_group(hgroup("[1]", x));

  cbp = meter_group(checkbox("[0] Bypass [tooltip: When this is checked the compressor has no effect]"));

  gainview = co.compression_gain_mono(ratio,threshold,attack,release) : ba.linear2db :
	           meter_group(hbargraph("[1] Compressor Gain [unit:dB] [tooltip: Current gain of the compressor in dB]",-50,+10));

	displaygain = _ <: _, abs : _, gainview : attach;

	gs_mono_compressor = displaygain(co.compressor_mono(ratio,threshold,attack,release)) : *(makeupgain);

	ctl_group(x) = kctl_group(hgroup("[3] Compression Control", x));
    ratio = ctl_group(vslider("[0] Ratio [style:knob]", 5, 1, 20, 0.1));
	  threshold = ctl_group(vslider("[1] Threshold [unit:dB] [style:knob]", -30, -100, 10, 0.1));
	  attack = ctl_group(vslider("[1] Attack [unit:ms] [style:knob] [scale:log] ", 50, 1, 1000, 0.1)) : *(0.001) : max(1/ma.SR);
	  release = ctl_group(vslider("[2] Release [unit:ms] [style: knob] [scale:log]", 500, 1, 1000, 0.1)) : *(0.001) : max(1/ma.SR);

  makeupgain = comp_group(hslider("[5] Makeup Gain [unit:dB]", 40, -96, 96, 0.1)) : ba.db2linear;
};

//process = fl_in : gs_m_comp : fl_out ;


// =======================================================
// ================================================= GUI =
// =======================================================

flute_group(x) = vgroup(" ----- FLUTE -----", x);
dbass_group(x) = vgroup(" ----- DOUBLE BASS -----", x);
bsax_group(x) = vgroup(" ----- BARI SAX -----", x);
dbat_group(x) = hgroup("Amplification", x);

dly_group(x) = hgroup("", x);
met_group(x) = vgroup("", x);

vmeter(x)	= attach(x, envelop(x) : vbargraph("[unit:dB]", -70, 0));
hmeter(x)	= attach(x, envelop(x) : hbargraph("[unit:dB]", -70, 0));

// =======================================================
// ========================================= DEFINITIONS =
// =======================================================

envelop = abs : max(ba.db2linear(-70)) : ba.linear2db : min(10)  : max ~ -(80.0/ma.SR);

mt2samp = *(343.00/ma.SR);

in_gain = vslider("[1] Gain [unit:dB] [style:knob]", -20, -96, 12, 0.1) : ba.db2linear;

// =======================================================
// ===================================== INPUT SELECTION =
// =======================================================

input_selector = _,_,_,_,_,_,_,_,_,_,_,_ : !,!,!,!,!,!,!,!,_,_,_,! ;

flute_sel = _,_,_ : ba.selectn(3,0) : *(in_gain) : hmeter ;
dbass_sel = _,_,_ : ba.selectn(3,0) : *(in_gain) : hmeter ;
bsax_sel = _,_,_ : ba.selectn(3,0) : *(in_gain) : hmeter ;

process = input_selector <: flute_sel, dbass_sel, bsax_sel : gs_m_comp,gs_m_comp,gs_m_comp : flute_out, dbass_out, bsax_out :> hmeter, hmeter, hmeter, hmeter, hmeter, hmeter ;
