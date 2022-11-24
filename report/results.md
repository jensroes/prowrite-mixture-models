---
title: "Modelling writing hesitations in text production as finite mixture model"
author: "Jens Roeser"
date: "Compiled Nov 24 2022"
output: 
  rmdformats::downcute:
    keep_md: true
    self_contained: true
    thumbnails: false # for images
    lightbox: true
    gallery: false
    highlight: tango
    use_bookdown: true # for cross references
bibliography: references.bib
csl: apa.csl
link-citations: yes
---
  





# SPL2

## Model comparisons




<table class="table" style="font-size: 11px; margin-left: auto; margin-right: auto;border-bottom: 0;">
<caption style="font-size: initial !important;">(\#tab:spl2)SPL2 data. Model comparisons. The top row shows the models with the highest predictive performance. Standard error is shown in parentheses.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">All transitions</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Before sentence</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Before word</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Within word</div></th>
</tr>
  <tr>
   <th style="text-align:left;"> Model </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;width: 8em; "> Bimodal log-normal </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -103,278 (227) </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -15,127 (65) </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -48,526 (142) </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -39,329 (104) </td>
  </tr>
  <tr>
   <td style="text-align:left;width: 8em; "> Unimodal log-normal (unequal variance) </td>
   <td style="text-align:right;"> -1,703 (71) </td>
   <td style="text-align:right;"> -104,981 (238) </td>
   <td style="text-align:right;"> -100 (14) </td>
   <td style="text-align:right;"> -15,226 (62) </td>
   <td style="text-align:right;"> -934 (46) </td>
   <td style="text-align:right;"> -49,459 (148) </td>
   <td style="text-align:right;"> -583 (45) </td>
   <td style="text-align:right;"> -39,912 (123) </td>
  </tr>
  <tr>
   <td style="text-align:left;width: 8em; "> Unimodal log-normal </td>
   <td style="text-align:right;"> -3,378 (81) </td>
   <td style="text-align:right;"> -106,656 (231) </td>
   <td style="text-align:right;"> -100 (14) </td>
   <td style="text-align:right;"> -15,226 (62) </td>
   <td style="text-align:right;"> -1,069 (45) </td>
   <td style="text-align:right;"> -49,595 (145) </td>
   <td style="text-align:right;"> -640 (50) </td>
   <td style="text-align:right;"> -39,969 (127) </td>
  </tr>
  <tr>
   <td style="text-align:left;width: 8em; "> Unimodal Gaussian </td>
   <td style="text-align:right;"> -34,837 (440) </td>
   <td style="text-align:right;"> -138,115 (482) </td>
   <td style="text-align:right;"> -1,698 (59) </td>
   <td style="text-align:right;"> -16,825 (64) </td>
   <td style="text-align:right;"> -11,945 (330) </td>
   <td style="text-align:right;"> -60,471 (363) </td>
   <td style="text-align:right;"> -9,197 (1,804) </td>
   <td style="text-align:right;"> -48,527 (1,828) </td>
  </tr>
</tbody>
<tfoot>
<tr><td style="padding: 0; " colspan="100%"><span style="font-style: italic;">Note: </span></td></tr>
<tr><td style="padding: 0; " colspan="100%">
<sup></sup> $\widehat{elpd}$ = predictive performance indicated as expected log pointwise predictive density; $\Delta\widehat{elpd}$ = difference in predictive performance relative to the model with the highest predictive performance in the top row.</td></tr>
</tfoot>
</table>

## Posterior parameter estimates of mixture model


<div class="figure" style="text-align: center">
<img src="results_files/figure-html/spl2post-1.png" alt="SPL2. Posterior parameter distribution"  />
<p class="caption">(\#fig:spl2post)SPL2. Posterior parameter distribution</p>
</div>



# PlanTra

## Model comparisons




<table class="table" style="font-size: 11px; margin-left: auto; margin-right: auto;border-bottom: 0;">
<caption style="font-size: initial !important;">(\#tab:plantra)PlanTra data. Model comparisons. The top row shows the models with the highest predictive performance. Standard error is shown in parentheses.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">All transitions</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Before sentence</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Before word</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Within word</div></th>
</tr>
  <tr>
   <th style="text-align:left;"> Model </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;width: 8em; "> Bimodal log-normal </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -52,065 (162) </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -11,739 (82) </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -21,917 (104) </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -18,498 (78) </td>
  </tr>
  <tr>
   <td style="text-align:left;width: 8em; "> Unimodal log-normal </td>
   <td style="text-align:right;"> -1,809 (62) </td>
   <td style="text-align:right;"> -53,874 (171) </td>
   <td style="text-align:right;"> -312 (25) </td>
   <td style="text-align:right;"> -12,051 (77) </td>
   <td style="text-align:right;"> -569 (33) </td>
   <td style="text-align:right;"> -22,486 (105) </td>
   <td style="text-align:right;"> -399 (43) </td>
   <td style="text-align:right;"> -18,897 (101) </td>
  </tr>
  <tr>
   <td style="text-align:left;width: 8em; "> Unimodal log-normal (unequal variance) </td>
   <td style="text-align:right;"> -1,201 (61) </td>
   <td style="text-align:right;"> -53,265 (173) </td>
   <td style="text-align:right;"> -313 (25) </td>
   <td style="text-align:right;"> -12,052 (77) </td>
   <td style="text-align:right;"> -570 (33) </td>
   <td style="text-align:right;"> -22,487 (105) </td>
   <td style="text-align:right;"> -401 (44) </td>
   <td style="text-align:right;"> -18,899 (101) </td>
  </tr>
  <tr>
   <td style="text-align:left;width: 8em; "> Unimodal Gaussian </td>
   <td style="text-align:right;"> -17,868 (349) </td>
   <td style="text-align:right;"> -69,932 (394) </td>
   <td style="text-align:right;"> -3,215 (93) </td>
   <td style="text-align:right;"> -14,954 (106) </td>
   <td style="text-align:right;"> -6,325 (228) </td>
   <td style="text-align:right;"> -28,242 (257) </td>
   <td style="text-align:right;"> -5,522 (749) </td>
   <td style="text-align:right;"> -24,020 (771) </td>
  </tr>
</tbody>
<tfoot>
<tr><td style="padding: 0; " colspan="100%"><span style="font-style: italic;">Note: </span></td></tr>
<tr><td style="padding: 0; " colspan="100%">
<sup></sup> $\widehat{elpd}$ = predictive performance indicated as expected log pointwise predictive density; $\Delta\widehat{elpd}$ = difference in predictive performance relative to the model with the highest predictive performance in the top row.</td></tr>
</tfoot>
</table>

## Posterior parameter estimates of mixture model


<div class="figure" style="text-align: center">
<img src="results_files/figure-html/plantrapost-1.png" alt="PlanTra. Posterior parameter distribution"  />
<p class="caption">(\#fig:plantrapost)PlanTra. Posterior parameter distribution</p>
</div>





# LIFT

## Model comparisons




<table class="table" style="font-size: 11px; margin-left: auto; margin-right: auto;border-bottom: 0;">
<caption style="font-size: initial !important;">(\#tab:lift)LIFT data. Model comparisons. The top row shows the models with the highest predictive performance. Standard error is shown in parentheses.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">All transitions</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Before sentence</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Before word</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Within word</div></th>
</tr>
  <tr>
   <th style="text-align:left;"> Model </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\Delta\widehat{elpd}$ </th>
   <th style="text-align:right;"> $\widehat{elpd}$ </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;width: 8em; "> Bimodal log-normal </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -280,027 (331) </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -228,441 (322) </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -390,349 (391) </td>
   <td style="text-align:right;"> -- </td>
   <td style="text-align:right;"> -337,088 (302) </td>
  </tr>
  <tr>
   <td style="text-align:left;width: 8em; "> Unimodal log-normal </td>
   <td style="text-align:right;"> -7,519 (146) </td>
   <td style="text-align:right;"> -287,545 (377) </td>
   <td style="text-align:right;"> -6,252 (123) </td>
   <td style="text-align:right;"> -234,693 (342) </td>
   <td style="text-align:right;"> -8,573 (142) </td>
   <td style="text-align:right;"> -398,922 (417) </td>
   <td style="text-align:right;"> -5,237 (145) </td>
   <td style="text-align:right;"> -342,325 (368) </td>
  </tr>
  <tr>
   <td style="text-align:left;width: 8em; "> Unimodal log-normal (unequal variance) </td>
   <td style="text-align:right;"> -5,401 (122) </td>
   <td style="text-align:right;"> -285,428 (361) </td>
   <td style="text-align:right;"> -6,255 (123) </td>
   <td style="text-align:right;"> -234,696 (342) </td>
   <td style="text-align:right;"> -8,555 (142) </td>
   <td style="text-align:right;"> -398,904 (417) </td>
   <td style="text-align:right;"> -5,233 (145) </td>
   <td style="text-align:right;"> -342,321 (368) </td>
  </tr>
  <tr>
   <td style="text-align:left;width: 8em; "> Unimodal Gaussian </td>
   <td style="text-align:right;"> -83,305 (1,657) </td>
   <td style="text-align:right;"> -363,332 (1,745) </td>
   <td style="text-align:right;"> -68,376 (977) </td>
   <td style="text-align:right;"> -296,817 (1,065) </td>
   <td style="text-align:right;"> -96,164 (1,599) </td>
   <td style="text-align:right;"> -486,513 (1,700) </td>
   <td style="text-align:right;"> -61,217 (2,552) </td>
   <td style="text-align:right;"> -398,306 (2,632) </td>
  </tr>
</tbody>
<tfoot>
<tr><td style="padding: 0; " colspan="100%"><span style="font-style: italic;">Note: </span></td></tr>
<tr><td style="padding: 0; " colspan="100%">
<sup></sup> $\widehat{elpd}$ = predictive performance indicated as expected log pointwise predictive density; $\Delta\widehat{elpd}$ = difference in predictive performance relative to the model with the highest predictive performance in the top row.</td></tr>
</tfoot>
</table>

## Posterior parameter estimates of mixture model




<div class="figure" style="text-align: center">
<img src="results_files/figure-html/liftpost-1.png" alt="LIFT. Posterior parameter distribution"  />
<p class="caption">(\#fig:liftpost)LIFT. Posterior parameter distribution</p>
</div>


# Cross-task / data set comparisons









<div class="figure" style="text-align: center">
<img src="results_files/figure-html/crossstudypost-1.png" alt="Across studies. Posterior parameter distribution"  />
<p class="caption">(\#fig:crossstudypost)Across studies. Posterior parameter distribution</p>
</div>







<table class="table" style="font-size: 10px; margin-left: auto; margin-right: auto;border-bottom: 0;">
<caption style="font-size: initial !important;">(\#tab:effects)Mixture model results of transition duration with predictor estimates for the distribution of short and hesitant transition durations (on log scale) and the probability of hesitant transitions (on logit scale). Estimates are shown with 95% PI.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="1"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Short transition duration</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Slowdown for hesitant transitions</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Probability of hesitant transitions</div></th>
</tr>
  <tr>
   <th style="text-align:left;"> Predictor </th>
   <th style="text-align:right;"> Estimate </th>
   <th style="text-align:right;"> $BF_{10}$ </th>
   <th style="text-align:right;"> Estimate </th>
   <th style="text-align:right;"> $BF_{10}$ </th>
   <th style="text-align:right;"> Estimate </th>
   <th style="text-align:right;"> $BF_{10}$ </th>
  </tr>
 </thead>
<tbody>
  <tr grouplength="5"><td colspan="7" style="border-bottom: 1px solid;"><strong>Main effects</strong></td></tr>
<tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Dataset 1 (LIFT, SPL2) </td>
   <td style="text-align:right;"> -0.38 [-0.48 -- -0.27] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -0.22 [-0.28 -- -0.16] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -0.77 [-0.97 -- -0.57] </td>
   <td style="text-align:right;"> &gt; 100 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Dataset 2 (LIFT, PlanTra) </td>
   <td style="text-align:right;"> 0.05 [-0.02 -- 0.12] </td>
   <td style="text-align:right;"> 0.1 </td>
   <td style="text-align:right;"> -0.28 [-0.36 -- -0.19] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -0.47 [-0.63 -- -0.31] </td>
   <td style="text-align:right;"> &gt; 100 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Dataset 1 (SPL2, PlanTra) </td>
   <td style="text-align:right;"> 0.43 [0.32 -- 0.54] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -0.06 [-0.15 -- 0.03] </td>
   <td style="text-align:right;"> 0.11 </td>
   <td style="text-align:right;"> 0.31 [0.07 -- 0.54] </td>
   <td style="text-align:right;"> 3.42 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Location 1 (before sentence, before word) </td>
   <td style="text-align:right;"> 0.2 [0.16 -- 0.27] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> 0.55 [0.48 -- 0.63] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> 0.27 [0.07 -- 0.47] </td>
   <td style="text-align:right;"> 3.59 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Location 2 (before word / sentence, within word) </td>
   <td style="text-align:right;"> 0.39 [0.36 -- 0.42] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> 0.67 [0.59 -- 0.74] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> 1.69 [1.53 -- 1.85] </td>
   <td style="text-align:right;"> &gt; 100 </td>
  </tr>
  <tr grouplength="6"><td colspan="7" style="border-bottom: 1px solid;"><strong>Two-way interactions</strong></td></tr>
<tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Dataset 1 : Location 1 </td>
   <td style="text-align:right;"> -0.73 [-0.91 -- -0.59] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -0.39 [-0.53 -- -0.25] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -1.6 [-2.09 -- -1.08] </td>
   <td style="text-align:right;"> &gt; 100 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Dataset 1 : Location 2 </td>
   <td style="text-align:right;"> -0.51 [-0.6 -- -0.44] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -0.39 [-0.54 -- -0.25] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -1.06 [-1.45 -- -0.67] </td>
   <td style="text-align:right;"> &gt; 100 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Dataset 2 : Location 1 </td>
   <td style="text-align:right;"> -0.02 [-0.08 -- 0.04] </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> -0.01 [-0.2 -- 0.18] </td>
   <td style="text-align:right;"> 0.1 </td>
   <td style="text-align:right;"> -0.84 [-1.22 -- -0.46] </td>
   <td style="text-align:right;"> &gt; 100 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Dataset 2 : Location 2 </td>
   <td style="text-align:right;"> 0.06 [0.02 -- 0.09] </td>
   <td style="text-align:right;"> 1.3 </td>
   <td style="text-align:right;"> -0.08 [-0.28 -- 0.11] </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> -0.43 [-0.78 -- -0.09] </td>
   <td style="text-align:right;"> 4.02 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Dataset 3 : Location 1 </td>
   <td style="text-align:right;"> 0.71 [0.56 -- 0.89] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> 0.38 [0.18 -- 0.57] </td>
   <td style="text-align:right;"> 81.03 </td>
   <td style="text-align:right;"> 0.75 [0.17 -- 1.32] </td>
   <td style="text-align:right;"> 8.45 </td>
  </tr>
  <tr>
   <td style="text-align:left;padding-left: 2em;" indentlevel="1"> Dataset 3 : Location 2 </td>
   <td style="text-align:right;"> 0.57 [0.49 -- 0.66] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> 0.31 [0.1 -- 0.52] </td>
   <td style="text-align:right;"> 6.44 </td>
   <td style="text-align:right;"> 0.63 [0.17 -- 1.08] </td>
   <td style="text-align:right;"> 8.69 </td>
  </tr>
</tbody>
<tfoot>
<tr><td style="padding: 0; " colspan="100%"><span style="font-style: italic;">Note: </span></td></tr>
<tr><td style="padding: 0; " colspan="100%">
<sup></sup> Colon indicates interactions. PI is the probability interval. $BF_{10}$ is the evidence in favour of the alternative hypothesis over the null hypothesis.</td></tr>
</tfoot>
</table>





<table class="table" style="font-size: 10px; margin-left: auto; margin-right: auto;border-bottom: 0;">
<caption style="font-size: initial !important;">(\#tab:cellmeans)By-transition location differences for transition duration estimates inferred from mixture model. Differences are shown on the log scale (for durations) and logit scale for probability of hesitant transitions. 95% PIs in brackets.</caption>
 <thead>
<tr>
<th style="empty-cells: hide;border-bottom:hidden;" colspan="2"></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Short interval durations</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Slowdown for hesitant transitions</div></th>
<th style="border-bottom:hidden;padding-bottom:0; padding-left:3px;padding-right:3px;text-align: center; " colspan="2"><div style="border-bottom: 1px solid #ddd; padding-bottom: 5px; ">Probability of hesitant transitions</div></th>
</tr>
  <tr>
   <th style="text-align:left;"> Transition location </th>
   <th style="text-align:left;"> Comparisons </th>
   <th style="text-align:right;"> Est. with 95% PI </th>
   <th style="text-align:right;"> BF$_{10}$ </th>
   <th style="text-align:right;"> Est. with 95% PI </th>
   <th style="text-align:right;"> BF$_{10}$ </th>
   <th style="text-align:right;"> Est. with 95% PI </th>
   <th style="text-align:right;"> BF$_{10}$ </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="3"> before sentence </td>
   <td style="text-align:left;"> LIFT - PlanTra </td>
   <td style="text-align:right;"> 0.06 [-0.02 -- 0.14] </td>
   <td style="text-align:right;"> 0.12 </td>
   <td style="text-align:right;"> -0.31 [-0.47 -- -0.16] </td>
   <td style="text-align:right;"> 78.6 </td>
   <td style="text-align:right;"> -1.03 [-1.32 -- -0.74] </td>
   <td style="text-align:right;"> &gt; 100 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> LIFT - SPL2 </td>
   <td style="text-align:right;"> -0.91 [-1.1 -- -0.75] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -0.54 [-0.66 -- -0.43] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -1.92 [-2.33 -- -1.47] </td>
   <td style="text-align:right;"> &gt; 100 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> SPL2 - PlanTra </td>
   <td style="text-align:right;"> 0.97 [0.8 -- 1.17] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> 0.23 [0.08 -- 0.39] </td>
   <td style="text-align:right;"> 4.81 </td>
   <td style="text-align:right;"> 0.89 [0.4 -- 1.35] </td>
   <td style="text-align:right;"> 82.58 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="3"> before word </td>
   <td style="text-align:left;"> LIFT - PlanTra </td>
   <td style="text-align:right;"> 0.08 [0 -- 0.15] </td>
   <td style="text-align:right;"> 0.32 </td>
   <td style="text-align:right;"> -0.3 [-0.41 -- -0.19] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -0.19 [-0.45 -- 0.07] </td>
   <td style="text-align:right;"> 0.38 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> LIFT - SPL2 </td>
   <td style="text-align:right;"> -0.18 [-0.28 -- -0.09] </td>
   <td style="text-align:right;"> 29.86 </td>
   <td style="text-align:right;"> -0.15 [-0.23 -- -0.08] </td>
   <td style="text-align:right;"> 41.79 </td>
   <td style="text-align:right;"> -0.33 [-0.6 -- -0.06] </td>
   <td style="text-align:right;"> 2.6 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> SPL2 - PlanTra </td>
   <td style="text-align:right;"> 0.26 [0.16 -- 0.37] </td>
   <td style="text-align:right;"> &gt; 100 </td>
   <td style="text-align:right;"> -0.15 [-0.26 -- -0.03] </td>
   <td style="text-align:right;"> 1.19 </td>
   <td style="text-align:right;"> 0.14 [-0.19 -- 0.48] </td>
   <td style="text-align:right;"> 0.24 </td>
  </tr>
  <tr>
   <td style="text-align:left;vertical-align: middle !important;" rowspan="3"> within word </td>
   <td style="text-align:left;"> LIFT - PlanTra </td>
   <td style="text-align:right;"> 0.01 [-0.06 -- 0.08] </td>
   <td style="text-align:right;"> 0.04 </td>
   <td style="text-align:right;"> -0.22 [-0.39 -- -0.06] </td>
   <td style="text-align:right;"> 2.91 </td>
   <td style="text-align:right;"> -0.18 [-0.46 -- 0.11] </td>
   <td style="text-align:right;"> 0.31 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> LIFT - SPL2 </td>
   <td style="text-align:right;"> -0.04 [-0.12 -- 0.06] </td>
   <td style="text-align:right;"> 0.06 </td>
   <td style="text-align:right;"> 0.04 [-0.09 -- 0.17] </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> -0.07 [-0.35 -- 0.23] </td>
   <td style="text-align:right;"> 0.17 </td>
  </tr>
  <tr>
   
   <td style="text-align:left;"> SPL2 - PlanTra </td>
   <td style="text-align:right;"> 0.05 [-0.05 -- 0.15] </td>
   <td style="text-align:right;"> 0.08 </td>
   <td style="text-align:right;"> -0.27 [-0.45 -- -0.08] </td>
   <td style="text-align:right;"> 4.94 </td>
   <td style="text-align:right;"> -0.11 [-0.46 -- 0.24] </td>
   <td style="text-align:right;"> 0.22 </td>
  </tr>
</tbody>
<tfoot>
<tr><td style="padding: 0; " colspan="100%"><span style="font-style: italic;">Note: </span></td></tr>
<tr><td style="padding: 0; " colspan="100%">
<sup></sup> PIs are probability intervals. $BF_{10}$ is the evidence in favour of the alternative hypothesis over the null hypothesis.</td></tr>
</tfoot>
</table>



# References
