# BRFSS 2015 Codebook (Land-Line and Cell-Phone data)

Converted from `codebook15_llcp.pdf` (CDC, report dated August 23, 2016; 137 pages).
Source of truth is the PDF. This file is a machine conversion. Checks run on 2026-09-25: 330 variables found, matching the 330 columns of `2015.csv` one-to-one; for every variable the Frequency column sums to 441,456 (the 2015 row count); 104 value rows across 10 variables (`_STATE`, `DIABETE3`, `SEX`, `_AGEG5YR`, `GENHLTH`, `_RFHYPE5`, `EXERANY2`, `SMOKE100`, `_BMI5CAT`, `EDUCA`) were compared to counts from `2015.csv` with 0 mismatches. Not checked: label text (copied as printed, so a few titles are cut off in the PDF itself) and Percentage columns. When a variable has several `Notes:` lines, they are joined into one Notes bullet.

## How to read an entry

- **Value** is the code stored in the CSV. **Value Label** is what the code means.
- **Frequency** is the number of respondent records with that code. **Percentage** is that count divided by all 441,456 records. **Weighted Percentage** applies the survey weights, so it estimates the adult population, not just the sample.
- `BLANK` means the field is empty (question not asked, or skipped by survey logic).
- Codes like 7 / 77 / 777 (don't know), 9 / 99 / 999 (refused) and 88 (none) are **not real numbers**. Do not average them.
- **Type:** `Num` or `Char`. **Column** is the position in the original fixed-width file, not in the CSV.

## Variable index (330 variables)

| Variable | Title | Section | Type | Page |
|---|---|---|---|---|
| [_STATE](#state) | State FIPS Code | Section: 0.1 Record Identification | Num | 2 |
| [FMONTH](#fmonth) | File Month | Section: 0.8 Record Identification | Num | 3 |
| [IDATE](#idate) | Interview Date | Section: 0.9 Record Identification | Char | 4 |
| [IMONTH](#imonth) | Interview Month | Section: 0.10 Record Identification | Char | 4 |
| [IDAY](#iday) | Interview Day | Section: 0.11 Record Identification | Char | 5 |
| [IYEAR](#iyear) | Interview Year | Section: 0.12 Record Identification | Char | 6 |
| [DISPCODE](#dispcode) | Final Disposition | Section: 0.14 Record Identification | Num | 6 |
| [SEQNO](#seqno) | Annual Sequence Number | Section: 0.15 Record Identification | Num | 6 |
| [_PSU](#psu) | Primary Sampling Unit | Section: 0.16 Record Identification | Num | 6 |
| [CTELENUM](#ctelenum) | Correct telephone number? | LandLine: 0.20 Land Line Introduction | Num | 7 |
| [PVTRESD1](#pvtresd1) | Private Residence? | LandLine: 0.21 Land Line Introduction | Num | 7 |
| [COLGHOUS](#colghous) | Do you live in college housing? | LandLine: 0.22 Land Line Introduction | Num | 7 |
| [STATERES](#stateres) | Resident of State | LandLine: 0.23 Land Line Introduction | Num | 8 |
| [CELLFON3](#cellfon3) | Cellular Telephone | LandLine: 0.24 Land Line Introduction | Num | 8 |
| [LADULT](#ladult) | Are you 18 years of age or older? | LandLine: 0.25 Land Line Introduction | Num | 8 |
| [NUMADULT](#numadult) | Number of Adults in Household | LandLine: 0.26 Land Line Introduction | Num | 9 |
| [NUMMEN](#nummen) | Number of Adult men in Household | LandLine: 0.27 Land Line Introduction | Num | 9 |
| [NUMWOMEN](#numwomen) | Number of Adult women in Household | LandLine: 0.28 Land Line Introduction | Num | 10 |
| [CTELNUM1](#ctelnum1) | Correct Phone Number? | CellPhone: 0.29 Cell Phone Introduction | Num | 10 |
| [CELLFON2](#cellfon2) | Is this a cellular telephone? | CellPhone: 0.30 Cell Phone Introduction | Num | 10 |
| [CADULT](#cadult) | Are you 18 years of age or older? | CellPhone: 0.31 Cell Phone Introduction | Num | 11 |
| [PVTRESD2](#pvtresd2) | Do you live in a private residence? | CellPhone: 0.32 Cell Phone Introduction | Num | 11 |
| [CCLGHOUS](#cclghous) | Do you live in college housing? | CellPhone: 0.33 Cell Phone Introduction | Num | 11 |
| [CSTATE](#cstate) | Are you a resident of [STATE]? | CellPhone: 0.34 Cell Phone Introduction | Num | 12 |
| [LANDLINE](#landline) | Do you also have a landline telephone? | CellPhone: 0.36 Cell Phone Introduction | Num | 12 |
| [HHADULT](#hhadult) | Number of Adults in Household | CellPhone: 0.37 Cell Phone Introduction | Num | 12 |
| [GENHLTH](#genhlth) | General Health | Section: 1.1 Health Status | Num | 13 |
| [PHYSHLTH](#physhlth) | Number of Days Physical Health Not Good | Section: 2.1 Healthy Days — Health Related Quality of Life | Num | 13 |
| [MENTHLTH](#menthlth) | Number of Days Mental Health Not Good | Section: 2.2 Healthy Days — Health Related Quality of Life | Num | 13 |
| [POORHLTH](#poorhlth) | Poor Physical or Mental Health | Section: 2.3 Healthy Days — Health Related Quality of Life | Num | 14 |
| [HLTHPLN1](#hlthpln1) | Have any health care coverage | Section: 3.1 Health Care Access | Num | 14 |
| [PERSDOC2](#persdoc2) | Multiple Health Care Professionals | Section: 3.2 Health Care Access | Num | 14 |
| [MEDCOST](#medcost) | Could Not See Doctor Because of Cost | Section: 3.3 Health Care Access | Num | 15 |
| [CHECKUP1](#checkup1) | Length of time since last routine checkup | Section: 3.4 Health Care Access | Num | 15 |
| [BPHIGH4](#bphigh4) | Ever Told Blood Pressure High | Section: 4.1 Hypertension Awareness | Num | 16 |
| [BPMEDS](#bpmeds) | Currently Taking Blood Pressure Medication | Section: 4.2 Hypertension Awareness | Num | 16 |
| [BLOODCHO](#bloodcho) | Ever Had Blood Cholesterol Checked | Section: 5.1 Cholesterol Awareness | Num | 16 |
| [CHOLCHK](#cholchk) | How Long since Cholesterol Checked | Section: 5.2 Cholesterol Awareness | Num | 17 |
| [TOLDHI2](#toldhi2) | Ever Told Blood Cholesterol High | Section: 5.3 Cholesterol Awareness | Num | 17 |
| [CVDINFR4](#cvdinfr4) | Ever Diagnosed with Heart Attack | Section: 6.1 Chronic Health Conditions | Num | 17 |
| [CVDCRHD4](#cvdcrhd4) | Ever Diagnosed with Angina or Coronary Heart Disease | Section: 6.2 Chronic Health Conditions | Num | 18 |
| [CVDSTRK3](#cvdstrk3) | Ever Diagnosed with a Stroke | Section: 6.3 Chronic Health Conditions | Num | 18 |
| [ASTHMA3](#asthma3) | Ever Told Had Asthma | Section: 6.4 Chronic Health Conditions | Num | 18 |
| [ASTHNOW](#asthnow) | Still Have Asthma | Section: 6.5 Chronic Health Conditions | Num | 19 |
| [CHCSCNCR](#chcscncr) | Ever told) you had skin cancer? | Section: 6.6 Chronic Health Conditions | Num | 19 |
| [CHCOCNCR](#chcocncr) | Ever told) you had any other types of cancer? | Section: 6.7 Chronic Health Conditions | Num | 19 |
| [CHCCOPD1](#chccopd1) | Ever told) you have chronic obstructive pulmonary disease, emphysema or chronic bronchitis? | Section: 6.8 Chronic Health Conditions | Num | 20 |
| [HAVARTH3](#havarth3) | Told Have Arthritis | Section: 6.9 Chronic Health Conditions | Num | 20 |
| [ADDEPEV2](#addepev2) | Ever told you had a depressive disorder | Section: 6.10 Chronic Health Conditions | Num | 20 |
| [CHCKIDNY](#chckidny) | Ever told) you have kidney disease? | Section: 6.11 Chronic Health Conditions | Num | 21 |
| [DIABETE3](#diabete3) | Ever told) you have diabetes | Section: 6.12 Chronic Health Conditions | Num | 21 |
| [DIABAGE2](#diabage2) | Age When Told Diabetic | Section: 6.13 Chronic Health Conditions | Num | 21 |
| [SEX](#sex) | Respondents Sex | Section: 7.1 Demographics | Num | 22 |
| [MARITAL](#marital) | Marital Status | Section: 7.6 Demographics | Num | 22 |
| [EDUCA](#educa) | Education Level | Section: 7.7 Demographics | Num | 22 |
| [RENTHOM1](#renthom1) | Own or Rent Home | Section: 7.8 Demographics | Num | 23 |
| [NUMHHOL2](#numhhol2) | Household Telephones | Section: 7.11 Demographics | Num | 23 |
| [NUMPHON2](#numphon2) | Residential Phones | Section: 7.12 Demographics | Num | 24 |
| [CPDEMO1](#cpdemo1) | Do you have a cell phone for personal use? | Section: 7.13 Demographics | Num | 24 |
| [VETERAN3](#veteran3) | Are You A Veteran | Section: 7.14 Demographics | Num | 25 |
| [EMPLOY1](#employ1) | Employment Status | Section: 7.15 Demographics | Num | 25 |
| [CHILDREN](#children) | Number of Children in Household | Section: 7.16 Demographics | Num | 25 |
| [INCOME2](#income2) | Income Level | Section: 7.17 Demographics | Num | 26 |
| [INTERNET](#internet) | Internet use in the past 30 days? | Section: 7.18 Demographics | Num | 26 |
| [WEIGHT2](#weight2) | Reported Weight in Pounds | Section: 7.19 Demographics | Num | 27 |
| [HEIGHT3](#height3) | Reported Height in Feet and Inches | Section: 7.20 Demographics | Num | 27 |
| [PREGNANT](#pregnant) | Pregnancy Status | Section: 7.21 Demographics | Num | 27 |
| [QLACTLM2](#qlactlm2) | Activity Limitation Due to Health Problems | Section: 7.22 Demographics | Num | 28 |
| [USEEQUIP](#useequip) | Health Problems Requiring Special Equipment | Section: 7.23 Demographics | Num | 28 |
| [BLIND](#blind) | Blind or Difficulty seeing | Section: 7.24 Demographics | Num | 28 |
| [DECIDE](#decide) | Difficulty Concentrating or Remembering | Section: 7.25 Demographics | Num | 29 |
| [DIFFWALK](#diffwalk) | Difficulty Walking or Climbing Stairs | Section: 7.26 Demographics | Num | 29 |
| [DIFFDRES](#diffdres) | Difficulty Dressing or Bathing | Section: 7.27 Demographics | Num | 29 |
| [DIFFALON](#diffalon) | Difficulty Doing Errands Alone | Section: 7.28 Demographics | Num | 30 |
| [SMOKE100](#smoke100) | Smoked at Least 100 Cigarettes | Section: 8.1 Tobacco Use | Num | 30 |
| [SMOKDAY2](#smokday2) | Frequency of Days Now Smoking | Section: 8.2 Tobacco Use | Num | 30 |
| [STOPSMK2](#stopsmk2) | Stopped Smoking in past 12 months | Section: 8.3 Tobacco Use | Num | 31 |
| [LASTSMK2](#lastsmk2) | Interval Since Last Smoked | Section: 8.4 Tobacco Use | Num | 31 |
| [USENOW3](#usenow3) | Use of Smokeless Tobacco Products | Section: 8.5 Tobacco Use | Num | 32 |
| [ALCDAY5](#alcday5) | Days in past 30 had alcoholic beverage | Section: 9.1 Alcohol Consumption | Num | 32 |
| [AVEDRNK2](#avedrnk2) | Avg alcoholic drinks per day in past 30 | Section: 9.2 Alcohol Consumption | Num | 33 |
| [DRNK3GE5](#drnk3ge5) | Binge Drinking | Section: 9.3 Alcohol Consumption | Num | 33 |
| [MAXDRNKS](#maxdrnks) | Most drinks on single occasion past 30 days | Section: 9.4 Alcohol Consumption | Num | 33 |
| [FRUITJU1](#fruitju1) | How many times did you drink 100 percent PURE fruit juices? | Section: 10.1 Fruits & Vegetables | Num | 34 |
| [FRUIT1](#fruit1) | How many times did you eat fruit? | Section: 10.2 Fruits & Vegetables | Num | 34 |
| [FVBEANS](#fvbeans) | How many times did you eat beans or lentils? | Section: 10.3 Fruits & Vegetables | Num | 35 |
| [FVGREEN](#fvgreen) | How many times did you eat dark green vegetables? | Section: 10.4 Fruits & Vegetables | Num | 35 |
| [FVORANG](#fvorang) | How many times did you eat orange-colored vegetables? | Section: 10.5 Fruits & Vegetables | Num | 36 |
| [VEGETAB1](#vegetab1) | How many times did you eat OTHER vegetables? | Section: 10.6 Fruits & Vegetables | Num | 36 |
| [EXERANY2](#exerany2) | Exercise in Past 30 Days | Section: 11.1 Exercise (Physical Activity) | Num | 37 |
| [EXRACT11](#exract11) | Type of Physical Activity | Section: 11.2 Exercise (Physical Activity) | Num | 38 |
| [EXEROFT1](#exeroft1) | How Many Times Walking, Running, Jogging, or Swimming | Section: 11.3 Exercise (Physical Activity) | Num | 40 |
| [EXERHMM1](#exerhmm1) | Minutes or Hours Walking, Running, Jogging, or Swimming | Section: 11.4 Exercise (Physical Activity) | Num | 40 |
| [EXRACT21](#exract21) | Other Type of Physical Activity Giving Most Exercise During Past Month | Section: 11.5 Exercise (Physical Activity) | Num | 41 |
| [EXEROFT2](#exeroft2) | How Many Times Walking, Running, Jogging, or Swimming | Section: 11.6 Exercise (Physical Activity) | Num | 43 |
| [EXERHMM2](#exerhmm2) | Minutes or Hours Walking, Running, Jogging, or Swimming | Section: 11.7 Exercise (Physical Activity) | Num | 43 |
| [STRENGTH](#strength) | How many times did you do physical activities or exercises to STRENGTHEN your muscles? | Section: 11.8 Exercise (Physical Activity) | Num | 44 |
| [LMTJOIN3](#lmtjoin3) | Limited Because of Joint Symptoms | Section: 12.1 Arthritis Burden | Num | 44 |
| [ARTHDIS2](#arthdis2) | Does Arthritis Affect Whether You Work | Section: 12.2 Arthritis Burden | Num | 44 |
| [ARTHSOCL](#arthsocl) | Social Activities Limited Because of Joint Symptoms | Section: 12.3 Arthritis Burden | Num | 45 |
| [JOINPAIN](#joinpain) | How Bad Was Joint Pain | Section: 12.4 Arthritis Burden | Num | 45 |
| [SEATBELT](#seatbelt) | How often use seatbelts in car? | Section: 13.1 Seatbelt Use | Num | 46 |
| [FLUSHOT6](#flushot6) | Adult flu shot/spray past 12 mos | Section: 14.1 Immunization | Num | 46 |
| [FLSHTMY2](#flshtmy2) | When did you (adult) receive your most recent seasonal flu shot/spray? | Section: 14.2 Immunization | Num | 47 |
| [IMFVPLAC](#imfvplac) | Where did you get your last flu shot/vaccine? | Section: 14.3 Immunization | Num | 47 |
| [PNEUVAC3](#pneuvac3) | Pneumonia shot ever | Section: 14.4 Immunization | Num | 48 |
| [HIVTST6](#hivtst6) | Ever tested HIV | Section: 15.1 HIV/AIDS | Num | 48 |
| [HIVTSTD3](#hivtstd3) | Month and Year of Last HIV Test | Section: 15.2 HIV/AIDS | Num | 48 |
| [WHRTST10](#whrtst10) | Location of last HIV test | Section: 15.3 HIV/AIDS | Num | 49 |
| [PDIABTST](#pdiabtst) | Had a test for high blood sugar or diabetes in the past three years? | Module: 1.1 Pre-Diabetes | Num | 49 |
| [PREDIAB1](#prediab1) | Ever been told by a doctor or other health professional that you have pre-diabetes or borderline diabetes? | Module: 1.2 Pre-Diabetes | Num | 50 |
| [INSULIN](#insulin) | Now Taking Insulin | Module: 2.1 Diabetes | Num | 50 |
| [BLDSUGAR](#bldsugar) | How Often Check Blood for Glucose | Module: 2.2 Diabetes | Num | 51 |
| [FEETCHK2](#feetchk2) | How Often Check Feet for Sores or Irritations | Module: 2.3 Diabetes | Num | 51 |
| [DOCTDIAB](#doctdiab) | Times Seen Health Professional for Diabetes | Module: 2.4 Diabetes | Num | 52 |
| [CHKHEMO3](#chkhemo3) | Times Checked for Glycosylated Hemoglobin | Module: 2.5 Diabetes | Num | 52 |
| [FEETCHK](#feetchk) | Times Feet Check for Sores/irritations | Module: 2.6 Diabetes | Num | 53 |
| [EYEEXAM](#eyeexam) | Last Eye Exam Where Pupils Were Dilated | Module: 2.7 Diabetes | Num | 53 |
| [DIABEYE](#diabeye) | Ever Told Diabetes Has Affected Eyes | Module: 2.8 Diabetes | Num | 54 |
| [DIABEDU](#diabedu) | Ever Taken Class in Managing Diabetes | Module: 2.9 Diabetes | Num | 54 |
| [PAINACT2](#painact2) | How many days hard to do usual activities in past 30 days | Module: 3.1 Healthy Days (Symptoms) | Num | 54 |
| [QLMENTL2](#qlmentl2) | How many days depressed in past 30 days | Module: 3.2 Healthy Days (Symptoms) | Num | 55 |
| [QLSTRES2](#qlstres2) | How many days felt anxious in past 30 days | Module: 3.3 Healthy Days (Symptoms) | Num | 55 |
| [QLHLTH2](#qlhlth2) | How many days full of energy in past 30 days | Module: 3.4 Healthy Days (Symptoms) | Num | 55 |
| [CAREGIV1](#caregiv1) | Provided regular care for family or friend | Module: 4.1 Caregiver | Num | 55 |
| [CRGVREL1](#crgvrel1) | Relationship Of Person To Whom You Are Giving Care? | Module: 4.2 Caregiver | Num | 56 |
| [CRGVLNG1](#crgvlng1) | How Long Provided Care For Person. | Module: 4.3 Caregiver | Num | 56 |
| [CRGVHRS1](#crgvhrs1) | How Many Hours Do You Provide Care For Person? | Module: 4.4 Caregiver | Num | 57 |
| [CRGVPRB1](#crgvprb1) | What Is The Major Health Problem, Illness, Disability For Care For Person? | Module: 4.5 Caregiver | Num | 57 |
| [CRGVPERS](#crgvpers) | Managed personal care | Module: 4.6 Caregiver | Num | 58 |
| [CRGVHOUS](#crgvhous) | Managed household tasks | Module: 4.7 Caregiver | Num | 58 |
| [CRGVMST2](#crgvmst2) | Which support do you MOST need that you are not getting? | Module: 4.8 Caregiver | Num | 59 |
| [CRGVEXPT](#crgvexpt) | Do you expect to have a relative you will need to provide care for? | Module: 4.9 Caregiver | Num | 59 |
| [VIDFCLT2](#vidfclt2) | Difficulty recognizing friend across street | Module: 5.1 Visual Impairment and Access to Eye Care | Num | 60 |
| [VIREDIF3](#viredif3) | Difficulty reading typed text | Module: 5.2 Visual Impairment and Access to Eye Care | Num | 60 |
| [VIPRFVS2](#viprfvs2) | Last time visited eye care provider | Module: 5.3 Visual Impairment and Access to Eye Care | Num | 61 |
| [VINOCRE2](#vinocre2) | Reason did not use eye doc past 12 mos | Module: 5.4 Visual Impairment and Access to Eye Care | Num | 61 |
| [VIEYEXM2](#vieyexm2) | When last eyexam | Module: 5.5 Visual Impairment and Access to Eye Care | Num | 62 |
| [VIINSUR2](#viinsur2) | Eye care health insurance | Module: 5.6 Visual Impairment and Access to Eye Care | Num | 62 |
| [VICTRCT4](#victrct4) | Hlth care pro said now have cataracts | Module: 5.7 Visual Impairment and Access to Eye Care | Num | 63 |
| [VIGLUMA2](#vigluma2) | Hlth care pro EVER said have glaucoma | Module: 5.8 Visual Impairment and Access to Eye Care | Num | 63 |
| [VIMACDG2](#vimacdg2) | Hlth care pro EVER said have macular degeneration | Module: 5.9 Visual Impairment and Access to Eye Care | Num | 64 |
| [CIMEMLOS](#cimemlos) | Have you experienced confusion or memory loss that is happening more often or is getting worse? | Module: 6.1 Cognitive Decline | Num | 64 |
| [CDHOUSE](#cdhouse) | Given up day-to-day chores due to confusion or memory loss | Module: 6.2 Cognitive Decline | Num | 65 |
| [CDASSIST](#cdassist) | Need assistance with day-to_day activities due to confusion or memory loss | Module: 6.3 Cognitive Decline | Num | 65 |
| [CDHELP](#cdhelp) | When you need help with day-to-day activities are you able to get it | Module: 6.4 Cognitive Decline | Num | 66 |
| [CDSOCIAL](#cdsocial) | Does confusion or memory loss interfere with work or social activities | Module: 6.5 Cognitive Decline | Num | 66 |
| [CDDISCUS](#cddiscus) | Have you discussed your confusion or memory loss with a health care professional? | Module: 6.6 Cognitive Decline | Num | 67 |
| [WTCHSALT](#wtchsalt) | Watching Sodium or Salt Intake | Module: 7.1 Sodium or Salt-Related Behavior | Num | 67 |
| [LONGWTCH](#longwtch) | How Long Watching Salt/Sodium Intake | Module: 7.2 Sodium or Salt-Related Behavior | Num | 68 |
| [DRADVISE](#dradvise) | Doctor Advised Reduced Sodium/Salt Intake | Module: 7.3 Sodium or Salt-Related Behavior | Num | 68 |
| [ASTHMAGE](#asthmage) | Age at Asthma Diagnosis | Module: 8.1 Adult Asthma History | Num | 68 |
| [ASATTACK](#asattack) | Asthma During Past 12 Months | Module: 8.2 Adult Asthma History | Num | 69 |
| [ASERVIST](#aservist) | Emergency Asthma Care During Past 12 Months | Module: 8.3 Adult Asthma History | Num | 69 |
| [ASDRVIST](#asdrvist) | Urgent Asthma Treatment During Past 12 Months | Module: 8.4 Adult Asthma History | Num | 69 |
| [ASRCHKUP](#asrchkup) | Routine Asthma Care During Past 12 Months | Module: 8.5 Adult Asthma History | Num | 70 |
| [ASACTLIM](#asactlim) | Activities Limited Because of Asthma During Past 12 Months | Module: 8.6 Adult Asthma History | Num | 70 |
| [ASYMPTOM](#asymptom) | Asthma Symptoms During Past 30 Days | Module: 8.7 Adult Asthma History | Num | 71 |
| [ASNOSLEP](#asnoslep) | Sleep Difficulty Because of Asthma During Past 30 Days | Module: 8.8 Adult Asthma History | Num | 71 |
| [ASTHMED3](#asthmed3) | Days used prescribed preventative asthma med in past 30 days | Module: 8.9 Adult Asthma History | Num | 72 |
| [ASINHALR](#asinhalr) | Times used asthma inhaler during an attack in past 30 days | Module: 8.10 Adult Asthma History | Num | 72 |
| [HAREHAB1](#harehab1) | Outpatient rehab after heart attack hosp stay | Module: 9.1 Cardiovascular Health | Num | 73 |
| [STREHAB1](#strehab1) | Outpatient rehab after hosp stay for stroke | Module: 9.2 Cardiovascular Health | Num | 73 |
| [CVDASPRN](#cvdasprn) | Take Aspirin Daily or Every Other Day | Module: 9.3 Cardiovascular Health | Num | 73 |
| [ASPUNSAF](#aspunsaf) | Health Makes Taking Aspirin Unsafe | Module: 9.4 Cardiovascular Health | Num | 74 |
| [RLIVPAIN](#rlivpain) | Take Aspirin to Relieve Pain | Module: 9.5 Cardiovascular Health | Num | 74 |
| [RDUCHART](#rduchart) | Take Aspirin to Reduce Chance of Heart Attack | Module: 9.6 Cardiovascular Health | Num | 74 |
| [RDUCSTRK](#rducstrk) | Take Aspirin to Reduce Chance of Stroke | Module: 9.7 Cardiovascular Health | Num | 75 |
| [ARTTODAY](#arttoday) | What Can You Do Because of Arthritis or Joint Symptoms | Module: 10.1 Arthritis Management | Num | 75 |
| [ARTHWGT](#arthwgt) | Dr. Suggest Lose Weight for Arthritis or Joint Symptoms | Module: 10.2 Arthritis Management | Num | 75 |
| [ARTHEXER](#arthexer) | Dr. Suggest Use of Physical Activity or Exercise for Arthritis or Joint Symptoms | Module: 10.3 Arthritis Management | Num | 76 |
| [ARTHEDU](#arthedu) | Ever Taken Class in Managing Arthritis or Joint Symptoms | Module: 10.4 Arthritis Management | Num | 76 |
| [TETANUS](#tetanus) | Received Tetanus Shot Since 2005? | Module: 11.1 Tetanus Diphtheria (TDAP) (Adults) | Num | 77 |
| [HPVADVC2](#hpvadvc2) | Have you ever had the HPV vaccination? | Module: 12.1 Adult Human Papillomavirus (HPV) - Vaccination | Num | 77 |
| [HPVADSHT](#hpvadsht) | How many HPV shots did you receive? | Module: 12.2 Adult Human Papillomavirus (HPV) - Vaccination | Num | 78 |
| [SHINGLE2](#shingle2) | Have you ever had the shingles or zoster vaccine? | Module: 13.1 Shingles (Zostavax or ZOS) | Num | 78 |
| [HADMAM](#hadmam) | Have You Ever Had a Mammogram | Module: 14.1 Breast and Cervical Cancer Screening | Num | 78 |
| [HOWLONG](#howlong) | How Long since Last Mammogram | Module: 14.2 Breast and Cervical Cancer Screening | Num | 79 |
| [HADPAP2](#hadpap2) | Ever Had a Pap Test | Module: 14.3 Breast and Cervical Cancer Screening | Num | 79 |
| [LASTPAP2](#lastpap2) | How Long Since Last Pap Test | Module: 14.4 Breast and Cervical Cancer Screening | Num | 80 |
| [HPVTEST](#hpvtest) | Have you ever had an HPV test? | Module: 14.5 Breast and Cervical Cancer Screening | Num | 80 |
| [HPLSTTST](#hplsttst) | How long since your last HPV test? | Module: 14.6 Breast and Cervical Cancer Screening | Num | 81 |
| [HADHYST2](#hadhyst2) | Had Hysterectomy | Module: 14.7 Breast and Cervical Cancer Screening | Num | 81 |
| [PROFEXAM](#profexam) | Ever Had Breast Physical Exam by Doctor | Module: 15.1 Clinical Breast Exam for Breast Cancer Screening | Num | 82 |
| [LENGEXAM](#lengexam) | How Long since Last Breast Physical Exam | Module: 15.2 Clinical Breast Exam for Breast Cancer Screening | Num | 82 |
| [BLDSTOOL](#bldstool) | Ever Had Blood Stool Test Using Home Kit | Module: 16.1 Colorectal Cancer Screening | Num | 83 |
| [LSTBLDS3](#lstblds3) | Time Since Last Blood Stool Test | Module: 16.2 Colorectal Cancer Screening | Num | 83 |
| [HADSIGM3](#hadsigm3) | Ever Had Sigmoidoscopy/Colonoscopy | Module: 16.3 Colorectal Cancer Screening | Num | 84 |
| [HADSGCO1](#hadsgco1) | Was your last test a sigmoidoscopy or colonoscopy? | Module: 16.4 Colorectal Cancer Screening | Num | 84 |
| [LASTSIG3](#lastsig3) | Time Since Last Sigmoidoscopy/Colonoscopy | Module: 16.5 Colorectal Cancer Screening | Num | 85 |
| [PCPSAAD2](#pcpsaad2) | Has a health professional EVER talked with you about the advantages of the PSA test? | Module: 17.1 Prostate Cancer Screening | Num | 85 |
| [PCPSADI1](#pcpsadi1) | Has a health professional EVER talked with you about the disadvantages of the PSA test? | Module: 17.2 Prostate Cancer Screening | Num | 86 |
| [PCPSARE1](#pcpsare1) | Has a doctor EVER recommended that you have a PSA test? | Module: 17.3 Prostate Cancer Screening | Num | 86 |
| [PSATEST1](#psatest1) | Ever Had PSA Test | Module: 17.4 Prostate Cancer Screening | Num | 86 |
| [PSATIME](#psatime) | Time Since Last PSA Test | Module: 17.5 Prostate Cancer Screening | Num | 87 |
| [PCPSARS1](#pcpsars1) | What was the MAIN reason you had this PSA test? | Module: 17.6 Prostate Cancer Screening | Num | 87 |
| [PCPSADE1](#pcpsade1) | Why was PSA test done? | Module: 18.1 Prostate Cancer Screening Decision Making | Num | 88 |
| [PCDMDECN](#pcdmdecn) | Who made the decision with you to have PSA test? | Module: 18.2 Prostate Cancer Screening Decision Making | Char | 88 |
| [SCNTMNY1](#scntmny1) | Times Past 12 Months Worried/Stressed About Having Enough Money To Pay Your Rent/Mortgage? | Module: 20.1 Social Context | Num | 89 |
| [SCNTMEL1](#scntmel1) | Times Past 12 Months Worried/Stressed About Having Enough Money To Buy Nutritious Meals? | Module: 20.2 Social Context | Num | 89 |
| [SCNTPAID](#scntpaid) | How Are You Generally Paid For The Work You Do | Module: 20.3 Social Context | Num | 90 |
| [SCNTWRK1](#scntwrk1) | How Many Hours Per Week Do You Work | Module: 20.4 Social Context | Num | 90 |
| [SCNTLPAD](#scntlpad) | How Were You Generally Paid For The Work You Did | Module: 20.5 Social Context | Num | 91 |
| [SCNTLWK1](#scntlwk1) | How Many Hours Per Week Did You Work | Module: 20.6 Social Context | Num | 91 |
| [SXORIENT](#sxorient) | Sexual orientation or gender identity | Module: 21.1 Sexual Orientation and Gender Identity | Num | 92 |
| [TRNSGNDR](#trnsgndr) | Do you consider yourself to be transgender? | Module: 21.2 Sexual Orientation and Gender Identity | Num | 92 |
| [RCSGENDR](#rcsgendr) | Gender of child | Module: 22.2 Random Child Selection | Num | 93 |
| [RCSRLTN2](#rcsrltn2) | Relationship to child | Module: 22.6 Random Child Selection | Num | 93 |
| [CASTHDX2](#casthdx2) | Hlth pro ever said child has asthma | Module: 23.1 Childhood Asthma Prevalence | Num | 94 |
| [CASTHNO2](#casthno2) | Child still have asthma? | Module: 23.2 Childhood Asthma Prevalence | Num | 94 |
| [EMTSUPRT](#emtsuprt) | How often get emotional support needed | Module: 24.1 Emotional Support and Life Satisfaction | Num | 94 |
| [LSATISFY](#lsatisfy) | Satisfaction with life | Module: 24.2 Emotional Support and Life Satisfaction | Num | 95 |
| [ADPLEASR](#adpleasr) | Days had little pleasure doing things | Module: 25.1 Anxiety and Depression | Num | 95 |
| [ADDOWN](#addown) | Days felt down, depressed or hopeless | Module: 25.2 Anxiety and Depression | Num | 95 |
| [ADSLEEP](#adsleep) | Days had trouble with sleep | Module: 25.3 Anxiety and Depression | Num | 96 |
| [ADENERGY](#adenergy) | Days were tired or had little energy | Module: 25.4 Anxiety and Depression | Num | 96 |
| [ADEAT1](#adeat1) | Days ate too little or too much | Module: 25.5 Anxiety and Depression | Num | 96 |
| [ADFAIL](#adfail) | Days felt like failure or let family down | Module: 25.6 Anxiety and Depression | Num | 97 |
| [ADTHINK](#adthink) | Days had trouble concentrating | Module: 25.7 Anxiety and Depression | Num | 97 |
| [ADMOVE](#admove) | Days talked to move slower or faster than usual | Module: 25.8 Anxiety and Depression | Num | 97 |
| [MISTMNT](#mistmnt) | Receiving medicine or treatment from health pro for emotional problem | Module: 25.9 Anxiety and Depression | Num | 98 |
| [ADANXEV](#adanxev) | Ever told you had an anxiety disorder | Module: 25.10 Anxiety and Depression | Num | 98 |
| [QSTVER](#qstver) | Questionnaire Version Identifier | State: 1.1 Questionnaire Version | Num | 99 |
| [QSTLANG](#qstlang) | Language identifier | State: 1.1 Questionnaire Language | Num | 99 |
| [EXACTOT1](#exactot1) | First Activity Other response description | Section: 11.3 Exercise (Physical Activity) | Char | 99 |
| [EXACTOT2](#exactot2) | Second Activity Other response description | Section: 11.7 Exercise (Physical Activity) | Char | 100 |
| [MSCODE](#mscode) | Metropolitan Status Code | Weighting: 1.2 Weighting Variables | Num | 100 |
| [_STSTR](#ststr) | Sample Design Stratification Variable | Weighting: 1.3 Weighting Variables | Num | 100 |
| [_STRWT](#strwt) | Stratum weight | Weighting: 1.4 Weighting Variables | Num | 101 |
| [_RAWRAKE](#rawrake) | Raw weighting factor used in raking | Weighting: 1.7 Weighting Variables | Num | 101 |
| [_WT2RAKE](#wt2rake) | Design weight use in raking | Weighting: 1.8 Weighting Variables | Num | 101 |
| [_CHISPNC](#chispnc) | Child Hispanic, Latino/a, or Spanish origin calculated variable | ChildDemographics: 1.01 Child Demographic Variables | Num | 102 |
| [_CRACE1](#crace1) | Child Non-Hispanic Race including Multiracial | ChildDemographics: 1.04 Child Demographic Variables | Num | 102 |
| [_CPRACE](#cprace) | Preferred Child Race Categories | ChildDemographics: 1.05 Child Demographic Variables | Num | 103 |
| [_CLLCPWT](#cllcpwt) | Final child weight: Land-line and Cell-Phone data | ChildLandandCellRaking: 1.5 Child Weighting Variables | Num | 103 |
| [_DUALUSE](#dualuse) | Dual Phone Use Categories | LandandCellRaking: 1.2 Weighting Variables | Num | 103 |
| [_DUALCOR](#dualcor) | Dual Phone Use Correction Factor | LandandCellRaking: 1.3 Weighting Variables | Num | 104 |
| [_LLCPWT](#llcpwt) | Final weight: Land-line and cell-phone data | LandandCellRaking: 1.21 Weighting Variables | Num | 104 |
| [_RFHLTH](#rfhlth) | Adults with good or better health | CalculatedVariables: 1.1 Calculated Variables | Num | 104 |
| [_HCVU651](#hcvu651) | Respondents aged 18-64 with health care coverage | CalculatedVariables: 3.1 Calculated Variables | Num | 105 |
| [_RFHYPE5](#rfhype5) | High Blood Pressure Calculated Variable | CalculatedVariables: 4.1 Calculated Variables | Num | 105 |
| [_CHOLCHK](#cholchk) | Cholesterol Checked Calculated Variable | CalculatedVariables: 5.1 Calculated Variables | Num | 105 |
| [_RFCHOL](#rfchol) | High Cholesterol Calculated Variable | CalculatedVariables: 5.2 Calculated Variables | Num | 106 |
| [_MICHD](#michd) | Ever had CHD or MI | CalculatedVariables: 6.1 Calculated Variables | Num | 106 |
| [_LTASTH1](#ltasth1) | Lifetime Asthma Calculated Variable | CalculatedVariables: 6.2 Calculated Variables | Num | 106 |
| [_CASTHM1](#casthm1) | Current Asthma Calculated Variable | CalculatedVariables: 6.3 Calculated Variables | Num | 107 |
| [_ASTHMS1](#asthms1) | Computed Asthma Status | CalculatedVariables: 6.4 Calculated Variables | Num | 107 |
| [_DRDXAR1](#drdxar1) | Respondents diagnosed with arthritis | CalculatedVariables: 6.5 Calculated Variables | Num | 107 |
| [_PRACE1](#prace1) | Computed Preferred Race | CalculatedVariables: 7.3 Calculated Race Variables | Num | 108 |
| [_MRACE1](#mrace1) | Calculated non-Hispanic Race including multiracial | CalculatedVariables: 7.4 Calculated Race Variables | Num | 109 |
| [_HISPANC](#hispanc) | Hispanic, Latino/a, or Spanish origin calculated variable | CalculatedVariables: 7.6 Calculated Race Variables | Num | 109 |
| [_RACE](#race) | Computed Race-Ethnicity grouping | CalculatedVariables: 7.7 Calculated Race Variables | Num | 110 |
| [_RACEG21](#raceg21) | Create Computed Non-Hispanic Whites/All Others Race Categories Race/Ethnic Group Codes Used In Post-Stratification Variable | CalculatedVariables: 7.8 Calculated Race Variables | Num | 110 |
| [_RACEGR3](#racegr3) | Computed Five level race/ethnicity category. | CalculatedVariables: 7.9 Calculated Race Variables | Num | 111 |
| [_RACE_G1](#race_g1) | Computed race groups used for internet prevalence tables | CalculatedVariables: 7.10 Calculated Race Variables | Num | 111 |
| [_AGEG5YR](#ageg5yr) | Reported age in five-year age categories calculated variable | CalculatedVariables: 7.11 Calculated Variables | Num | 112 |
| [_AGE65YR](#age65yr) | Reported age in two age groups calculated variable | CalculatedVariables: 7.12 Calculated Variables | Num | 112 |
| [_AGE80](#age80) | Imputed Age value collapsed above 80 | CalculatedVariables: 7.13 Calculated Variables | Num | 113 |
| [_AGE_G](#age_g) | Imputed age in six groups | CalculatedVariables: 7.14 Calculated Variables | Num | 113 |
| [HTIN4](#htin4) | Computed Height in Inches | CalculatedVariables: 7.15 Calculated Variables | Num | 114 |
| [HTM4](#htm4) | Computed Height in Meters | CalculatedVariables: 7.16 Calculated Variables | Num | 114 |
| [WTKG3](#wtkg3) | Computed Weight in Kilograms | CalculatedVariables: 7.17 Calculated Variables | Num | 114 |
| [_BMI5](#bmi5) | Computed body mass index | CalculatedVariables: 7.18 Calculated Variables | Num | 115 |
| [_BMI5CAT](#bmi5cat) | Computed body mass index categories | CalculatedVariables: 7.19 Calculated Variables | Num | 115 |
| [_RFBMI5](#rfbmi5) | Overweight or obese calculated variable | CalculatedVariables: 7.20 Calculated Variables | Num | 115 |
| [_CHLDCNT](#chldcnt) | Computed number of children in household | CalculatedVariables: 7.21 Calculated Variables | Num | 116 |
| [_EDUCAG](#educag) | Computed level of education completed categories | CalculatedVariables: 7.22 Calculated Variables | Num | 116 |
| [_INCOMG](#incomg) | Computed income categories | CalculatedVariables: 7.23 Calculated Variables | Num | 117 |
| [_SMOKER3](#smoker3) | Computed Smoking Status | CalculatedVariables: 8.1 Calculated Variables | Num | 117 |
| [_RFSMOK3](#rfsmok3) | Current Smoking Calculated Variable | CalculatedVariables: 8.2 Calculated Variables | Num | 118 |
| [DRNKANY5](#drnkany5) | Drink any alcoholic beverages in past 30 days | CalculatedVariables: 9.1 Calculated Variables | Num | 118 |
| [DROCDY3_](#drocdy3_) | Computed drink-occasions-per-day | CalculatedVariables: 9.2 Calculated Variables | Num | 118 |
| [_RFBING5](#rfbing5) | Binge Drinking Calculated Variable | CalculatedVariables: 9.3 Calculated Variables | Num | 119 |
| [_DRNKWEK](#drnkwek) | Computed number of drinks of alcohol beverages per week | CalculatedVariables: 9.4 Calculated Variables | Num | 119 |
| [_RFDRHV5](#rfdrhv5) | Heavy Alcohol Consumption Calculated Variable | CalculatedVariables: 9.5 Calculated Variables | Num | 119 |
| [FTJUDA1_](#ftjuda1_) | Computed Fruit Juice intake in times per day | CalculatedVariables: 10.1 Calculated Variables | Num | 120 |
| [FRUTDA1_](#frutda1_) | Computed Fruit intake in times per day | CalculatedVariables: 10.2 Calculated Variables | Num | 120 |
| [BEANDAY_](#beanday_) | Computed Bean intake in times per day | CalculatedVariables: 10.3 Calculated Variables | Num | 120 |
| [GRENDAY_](#grenday_) | Computed Dark Green Vegetable intake in times per day | CalculatedVariables: 10.4 Calculated Variables | Num | 120 |
| [ORNGDAY_](#orngday_) | Computed Orange-Colored Vegetable intake in times per day | CalculatedVariables: 10.5 Calculated Variables | Num | 121 |
| [VEGEDA1_](#vegeda1_) | Computed Other Vegetable intake in times per day | CalculatedVariables: 10.6 Calculated Variables | Num | 121 |
| [_MISFRTN](#misfrtn) | The number of missing fruit responses | CalculatedVariables: 10.7 Calculated Variables | Num | 121 |
| [_MISVEGN](#misvegn) | The number of missing vegetable responses | CalculatedVariables: 10.8 Calculated Variables | Num | 122 |
| [_FRTRESP](#frtresp) | Missing any fruit responses | CalculatedVariables: 10.9 Calculated Variables | Num | 122 |
| [_VEGRESP](#vegresp) | Missing any vegetable responses | CalculatedVariables: 10.10 Calculated Variables | Num | 122 |
| [_FRUTSUM](#frutsum) | Total fruits consumed per day | CalculatedVariables: 10.11 Calculated Variables | Num | 122 |
| [_VEGESUM](#vegesum) | Total vegetables consumed per day | CalculatedVariables: 10.12 Calculated Variables | Num | 123 |
| [_FRTLT1](#frtlt1) | Consume Fruit 1 or more times per day | CalculatedVariables: 10.13 Calculated Variables | Num | 123 |
| [_VEGLT1](#veglt1) | Consume Vegetables 1 or more times per day | CalculatedVariables: 10.14 Calculated Variables | Num | 123 |
| [_FRT16](#frt16) | Reported consuming Fruit >16 per day | CalculatedVariables: 10.15 Calculated Variables | Num | 124 |
| [_VEG23](#veg23) | Reported consuming Vegetables >23 per day | CalculatedVariables: 10.16 Calculated Variables | Num | 124 |
| [_FRUITEX](#fruitex) | Fruit Exclusion from analyses | CalculatedVariables: 10.17 Calculated Variables | Num | 124 |
| [_VEGETEX](#vegetex) | Vegetable Exclusion from analyses | CalculatedVariables: 10.18 Calculated Variables | Num | 125 |
| [_TOTINDA](#totinda) | Leisure Time Physical Activity Calculated Variable | CalculatedVariables: 11.1 Calculated Variables | Num | 125 |
| [METVL11_](#metvl11_) | Activity MET Value for First Activity | CalculatedVariables: 11.2 Calculated Variables | Num | 125 |
| [METVL21_](#metvl21_) | Activity MET Value for Second Activity | CalculatedVariables: 11.3 Calculated Variables | Num | 126 |
| [MAXVO2_](#maxvo2_) | Estimated Age-Gender Specific Maximum Oxygen Consumption | CalculatedVariables: 11.4 Calculated Variables | Num | 126 |
| [FC60_](#fc60_) | Estimated Functional Capacity | CalculatedVariables: 11.5 Calculated Variables | Num | 126 |
| [ACTIN11_](#actin11_) | Estimated Activity Intensity for First Activity | CalculatedVariables: 11.6 Calculated Variables | Num | 127 |
| [ACTIN21_](#actin21_) | Estimated Activity Intensity for Second Activity | CalculatedVariables: 11.7 Calculated Variables | Num | 127 |
| [PADUR1_](#padur1_) | Minutes of First Activity | CalculatedVariables: 11.8 Calculated Variables | Num | 127 |
| [PADUR2_](#padur2_) | Minutes of Second Activity | CalculatedVariables: 11.9 Calculated Variables | Num | 128 |
| [PAFREQ1_](#pafreq1_) | Physical Activity Frequency per Week for First Activity | CalculatedVariables: 11.10 Calculated Variables | Num | 128 |
| [PAFREQ2_](#pafreq2_) | Physical Activity Frequency per Week for Second Activity | CalculatedVariables: 11.11 Calculated Variables | Num | 128 |
| [_MINAC11](#minac11) | Minutes of Physical Activity per week for First Activity | CalculatedVariables: 11.12 Calculated Variables | Num | 129 |
| [_MINAC21](#minac21) | Minutes of Physical Activity per week for Second Activity | CalculatedVariables: 11.13 Calculated Variables | Num | 129 |
| [STRFREQ_](#strfreq_) | Strength Activity Frequency per Week | CalculatedVariables: 11.14 Calculated Variables | Num | 129 |
| [PAMISS1_](#pamiss1_) | Missing Physical Activity Data | CalculatedVariables: 11.15 Calculated Variables | Num | 130 |
| [PAMIN11_](#pamin11_) | Minutes of Physical Activity per week for First Activity | CalculatedVariables: 11.16 Calculated Variables | Num | 130 |
| [PAMIN21_](#pamin21_) | Minutes of Physical Activity per week for Second Activity | CalculatedVariables: 11.17 Calculated Variables | Num | 130 |
| [PA1MIN_](#pa1min_) | Minutes of total Physical Activity per week | CalculatedVariables: 11.18 Calculated Variables | Num | 131 |
| [PAVIG11_](#pavig11_) | Minutes of Vigorous Physical Activity per week for First Activity | CalculatedVariables: 11.19 Calculated Variables | Num | 131 |
| [PAVIG21_](#pavig21_) | Minutes of Vigorous Physical Activity per week for Second Activity | CalculatedVariables: 11.20 Calculated Variables | Num | 131 |
| [PA1VIGM_](#pa1vigm_) | Minutes of total Vigorous Physical Activity per week | CalculatedVariables: 11.21 Calculated Variables | Num | 131 |
| [_PACAT1](#pacat1) | Physical Activity Categories | CalculatedVariables: 11.22 Calculated Variables | Num | 132 |
| [_PAINDX1](#paindx1) | Physical Activity Index | CalculatedVariables: 11.23 Calculated Variables | Num | 132 |
| [_PA150R2](#pa150r2) | 150 Minute Physical Activity Calculated Variable | CalculatedVariables: 11.24 Calculated Variables | Num | 132 |
| [_PA300R2](#pa300r2) | 300 Minute Physical Activity Calculated Variable | CalculatedVariables: 11.25 Calculated Variables | Num | 133 |
| [_PA30021](#pa30021) | 300 Minute Physical Activity 2-Level Calculated Variable | CalculatedVariables: 11.26 Calculated Variables | Num | 133 |
| [_PASTRNG](#pastrng) | Muscle Strengthening Recommendation | CalculatedVariables: 11.27 Calculated Variables | Num | 133 |
| [_PAREC1](#parec1) | Aerobic and Strengthening Guideline | CalculatedVariables: 11.28 Calculated Variables | Num | 134 |
| [_PASTAE1](#pastae1) | Aerobic and Strengthening (2-level) | CalculatedVariables: 11.29 Calculated Variables | Num | 134 |
| [_LMTACT1](#lmtact1) | Limited usual activities | CalculatedVariables: 12.1 Calculated Variables | Num | 134 |
| [_LMTWRK1](#lmtwrk1) | Limited work activities | CalculatedVariables: 12.2 Calculated Variables | Num | 135 |
| [_LMTSCL1](#lmtscl1) | Limited social activities | CalculatedVariables: 12.3 Calculated Variables | Num | 135 |
| [_RFSEAT2](#rfseat2) | Always or Nearly Always Wear Seat Belts | CalculatedVariables: 13.1 Calculated Variables | Num | 135 |
| [_RFSEAT3](#rfseat3) | Always Wear Seat Belts | CalculatedVariables: 13.2 Calculated Variables | Num | 136 |
| [_FLSHOT6](#flshot6) | Flu Shot Calculated Variable | CalculatedVariables: 14.1 Calculated Variables | Num | 136 |
| [_PNEUMO2](#pneumo2) | Pneumonia Vaccination Calculated Variable | CalculatedVariables: 14.2 Calculated Variables | Num | 136 |
| [_AIDTST3](#aidtst3) | Ever been tested for HIV calculated variable | CalculatedVariables: 15.1 Calculated Variables | Num | 137 |

## _STATE
<a id="state"></a>

**State FIPS Code**

- Section: 0.1 Record Identification
- Type: Num
- Column (fixed-width file): 1-2
- PDF page: 2
- Description: State FIPS Code

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Alabama | 7,950 | 1.80 | 1.50 |
| 2 | Alaska | 3,657 | 0.83 | 0.22 |
| 4 | Arizona | 7,946 | 1.80 | 2.07 |
| 5 | Arkansas | 5,256 | 1.19 | 0.91 |
| 6 | California | 12,601 | 2.85 | 11.96 |
| 8 | Colorado | 13,537 | 3.07 | 1.67 |
| 9 | Connecticut | 11,899 | 2.70 | 1.13 |
| 10 | Delaware | 4,070 | 0.92 | 0.30 |
| 11 | District of Columbia | 3,994 | 0.90 | 0.22 |
| 12 | Florida | 9,739 | 2.21 | 6.44 |
| 13 | Georgia | 4,678 | 1.06 | 3.08 |
| 15 | Hawaii | 7,163 | 1.62 | 0.45 |
| 16 | Idaho | 5,802 | 1.31 | 0.49 |
| 17 | Illinois | 5,289 | 1.20 | 3.95 |
| 18 | Indiana | 6,067 | 1.37 | 2.01 |
| 19 | Iowa | 6,227 | 1.41 | 0.96 |
| 20 | Kansas | 23,236 | 5.26 | 0.87 |
| 21 | Kentucky | 8,806 | 1.99 | 1.36 |
| 22 | Louisiana | 4,716 | 1.07 | 1.42 |
| 23 | Maine | 9,063 | 2.05 | 0.43 |
| 24 | Maryland | 12,598 | 2.85 | 1.87 |
| 25 | Massachusetts | 9,294 | 2.11 | 2.16 |
| 26 | Michigan | 8,935 | 2.02 | 3.08 |
| 27 | Minnesota | 16,761 | 3.80 | 1.68 |
| 28 | Mississippi | 6,035 | 1.37 | 0.90 |
| 29 | Missouri | 7,307 | 1.66 | 1.87 |
| 30 | Montana | 6,051 | 1.37 | 0.32 |
| 31 | Nebraska | 17,561 | 3.98 | 0.57 |
| 32 | Nevada | 2,926 | 0.66 | 0.88 |
| 33 | New Hampshire | 7,022 | 1.59 | 0.43 |
| 34 | New Jersey | 11,465 | 2.60 | 2.78 |
| 35 | New Mexico | 6,734 | 1.53 | 0.63 |
| 36 | New York | 12,357 | 2.80 | 6.21 |
| 37 | North Carolina | 6,698 | 1.52 | 3.10 |
| 38 | North Dakota | 4,972 | 1.13 | 0.23 |
| 39 | Ohio | 11,929 | 2.70 | 3.59 |
| 40 | Oklahoma | 6,943 | 1.57 | 1.18 |
| 41 | Oregon | 5,359 | 1.21 | 1.26 |
| 42 | Pennsylvania | 5,740 | 1.30 | 4.03 |
| 44 | Rhode Island | 6,206 | 1.41 | 0.34 |
| 45 | South Carolina | 11,607 | 2.63 | 1.52 |
| 46 | South Dakota | 7,221 | 1.64 | 0.26 |
| 47 | Tennessee | 5,979 | 1.35 | 2.04 |
| 48 | Texas | 14,697 | 3.33 | 8.10 |
| 49 | Utah | 11,401 | 2.58 | 0.83 |
| 50 | Vermont | 6,489 | 1.47 | 0.20 |
| 51 | Virginia | 8,646 | 1.96 | 2.60 |
| 53 | Washington | 16,116 | 3.65 | 2.21 |
| 54 | West Virginia | 5,957 | 1.35 | 0.59 |
| 55 | Wisconsin | 6,188 | 1.40 | 1.78 |
| 56 | Wyoming | 5,492 | 1.24 | 0.18 |
| 66 | Guam | 1,669 | 0.38 | 0.04 |
| 72 | Puerto Rico | 5,405 | 1.22 | 1.12 |

## FMONTH
<a id="fmonth"></a>

**File Month**

- Section: 0.8 Record Identification
- Type: Num
- Column (fixed-width file): 17-18
- PDF page: 3
- Description: File Month

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | January | 44,300 | 10.03 | 11.79 |
| 2 | February | 37,154 | 8.42 | 7.88 |
| 3 | March | 35,066 | 7.94 | 7.56 |
| 4 | April | 40,560 | 9.19 | 10.46 |
| 5 | May | 33,506 | 7.59 | 7.03 |
| 6 | June | 33,177 | 7.52 | 6.95 |
| 7 | July | 41,296 | 9.35 | 9.94 |
| 8 | August | 33,062 | 7.49 | 6.50 |
| 9 | September | 33,273 | 7.54 | 6.85 |
| 10 | October | 42,246 | 9.57 | 12.16 |
| 11 | November | 34,398 | 7.79 | 6.50 |
| 12 | December | 33,418 | 7.57 | 6.37 |

## IDATE
<a id="idate"></a>

**Interview Date**

- Section: 0.9 Record Identification
- Type: Char
- Column (fixed-width file): 19-26
- PDF page: 4
- Description: Interview Date
- Notes: Due to the nature of the data or the size of the table for display, this data is not printed for this report

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## IMONTH
<a id="imonth"></a>

**Interview Month**

- Section: 0.10 Record Identification
- Type: Char
- Column (fixed-width file): 19-20
- PDF page: 4
- Description: Interview Month

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | January | 37,532 | 8.50 | 9.16 |
| 2 | February | 39,218 | 8.88 | 8.71 |
| 3 | March | 42,406 | 9.61 | 9.62 |
| 4 | April | 35,840 | 8.12 | 7.95 |
| 5 | May | 34,386 | 7.79 | 7.71 |
| 6 | June | 36,216 | 8.20 | 8.52 |
| 7 | July | 36,943 | 8.37 | 8.54 |
| 8 | August | 36,334 | 8.23 | 7.93 |
| 9 | September | 30,782 | 6.97 | 6.80 |
| 10 | October | 35,545 | 8.05 | 7.86 |
| 11 | November | 39,845 | 9.03 | 8.84 |
| 12 | December | 36,409 | 8.25 | 8.37 |

## IDAY
<a id="iday"></a>

**Interview Day**

- Section: 0.11 Record Identification
- Type: Char
- Column (fixed-width file): 21-22
- PDF page: 5
- Description: Interview Day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Interview Day | 12,586 | 2.85 | 2.65 |
| 2 |  | 16,197 | 3.67 | 3.06 |
| 3 |  | 16,649 | 3.77 | 3.14 |
| 4 |  | 16,229 | 3.68 | 3.24 |
| 5 |  | 15,105 | 3.42 | 3.04 |
| 6 |  | 16,408 | 3.72 | 3.40 |
| 7 |  | 17,175 | 3.89 | 3.53 |
| 8 |  | 17,398 | 3.94 | 3.67 |
| 9 |  | 18,669 | 4.23 | 4.16 |
| 10 |  | 16,810 | 3.81 | 3.72 |
| 11 |  | 17,037 | 3.86 | 3.81 |
| 12 |  | 17,089 | 3.87 | 3.81 |
| 13 |  | 16,536 | 3.75 | 3.96 |
| 14 |  | 17,052 | 3.86 | 3.94 |
| 15 |  | 15,931 | 3.61 | 3.81 |
| 16 |  | 15,917 | 3.61 | 3.69 |
| 17 |  | 14,925 | 3.38 | 3.46 |
| 18 |  | 14,759 | 3.34 | 3.40 |
| 19 |  | 14,233 | 3.22 | 3.37 |
| 20 |  | 14,424 | 3.27 | 3.60 |
| 21 |  | 14,642 | 3.32 | 3.48 |
| 22 |  | 14,078 | 3.19 | 3.39 |
| 23 |  | 13,445 | 3.05 | 3.22 |
| 24 |  | 11,459 | 2.60 | 2.70 |
| 25 |  | 10,330 | 2.34 | 2.49 |
| 26 |  | 10,388 | 2.35 | 2.63 |
| 27 |  | 10,677 | 2.42 | 2.68 |
| 28 |  | 11,019 | 2.50 | 2.68 |
| 29 |  | 9,806 | 2.22 | 2.48 |
| 30 |  | 9,491 | 2.15 | 2.44 |
| 31 |  | 4,992 | 1.13 | 1.34 |

## IYEAR
<a id="iyear"></a>

**Interview Year**

- Section: 0.12 Record Identification
- Type: Char
- Column (fixed-width file): 23-26
- PDF page: 6
- Description: Interview Year

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 2015 | Interview Year | 430,541 | 97.53 | 96.19 |
| 2016 |  | 10,915 | 2.47 | 3.81 |

## DISPCODE
<a id="dispcode"></a>

**Final Disposition**

- Section: 0.14 Record Identification
- Type: Num
- Column (fixed-width file): 32-35
- PDF page: 6
- Description: Final Disposition

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1100 | Completed Interview | 375,059 | 84.96 | 77.74 |
| 1200 | Partial Complete Interview | 66,397 | 15.04 | 22.26 |

## SEQNO
<a id="seqno"></a>

**Annual Sequence Number**

- Section: 0.15 Record Identification
- Type: Num
- Column (fixed-width file): 36-45
- PDF page: 6
- Description: Annual Sequence Number

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## _PSU
<a id="psu"></a>

**Primary Sampling Unit**

- Section: 0.16 Record Identification
- Type: Num
- Column (fixed-width file): 36-45
- PDF page: 6
- Description: Primary Sampling Unit (Equal to Annual Sequence Number)
- Notes: Value should be unique for a state for a year. Due to the nature of the data or the size of the table for display, this data is not printed for this report

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## CTELENUM
<a id="ctelenum"></a>

**Correct telephone number?**

- LandLine: 0.20 Land Line Introduction
- Type: Num
- Column (fixed-width file): 63
- PDF page: 7
- Prologue: Variable only on the land line survey
- Description: Correct Telephone Number?
- Notes: QSTVER > = 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to PVTRESD1 | 254,645 | 100.00 | 100.00 |
| BLANK | Missing | 186,811 |  |  |

## PVTRESD1
<a id="pvtresd1"></a>

**Private Residence?**

- LandLine: 0.21 Land Line Introduction
- Type: Num
- Column (fixed-width file): 64
- PDF page: 7
- Prologue: Variable only on the land line survey
- Description: Is this a private residence? [READ ONLY IF NECESSARY: “By private residence, we mean someplace like a house or apartment.”]
- Notes: QSTVER >= 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to STATERES | 254,600 | 99.98 | 99.96 |
| 2 | No----Go to COLGHOUS | 45 | 0.02 | 0.04 |
| BLANK | Missing | 186,811 |  |  |

## COLGHOUS
<a id="colghous"></a>

**Do you live in college housing?**

- LandLine: 0.22 Land Line Introduction
- Type: Num
- Column (fixed-width file): 65
- PDF page: 7
- Prologue: Variable only on the land line survey
- Description: Do you live in college housing?
- Notes: QSTVER >= 20; or PVTRESD1=1

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to STATERES | 45 | 100.00 | 100.00 |
| BLANK | Missing | 441,411 |  |  |

## STATERES
<a id="stateres"></a>

**Resident of State**

- LandLine: 0.23 Land Line Introduction
- Type: Num
- Column (fixed-width file): 66
- PDF page: 8
- Prologue: Variable only on the land line survey
- Description: Do you reside in ____(state)____?
- Notes: QSTVER >= 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to CELLFON3 | 254,643 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 186,813 |  |  |

## CELLFON3
<a id="cellfon3"></a>

**Cellular Telephone**

- LandLine: 0.24 Land Line Introduction
- Type: Num
- Column (fixed-width file): 67
- PDF page: 8
- Prologue: Variable only on the land line survey
- Description: Is this a cellular telephone? (Telephone service over the internet counts as landline service (includes Vonage, Magic Jack and other home-based phone services).)[Read only if necessary: “By cellular (or cell) telephone we mean a telephone that is mobile and usable outside of your neighborhood.”]
- Notes: QSTVER >= 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Not a cellular phone | 115,830 | 45.49 | 44.42 |
| 2 | Yes----Terminate Phone Call | 138,816 | 54.51 | 55.58 |
| BLANK | Missing | 186,810 |  |  |

## LADULT
<a id="ladult"></a>

**Are you 18 years of age or older?**

- LandLine: 0.25 Land Line Introduction
- Type: Num
- Column (fixed-width file): 68
- PDF page: 8
- Prologue: Variable only on the land line survey
- Description: Are you 18 years of age or older?
- Notes: QSTVER >= 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes, Male Respondent----Go to Survey Introduction | 18 | 40.00 | 28.87 |
| 2 | Yes, Female Respondent----Go to Survey Introduction | 27 | 60.00 | 71.13 |
| BLANK | Missing | 441,411 |  |  |

## NUMADULT
<a id="numadult"></a>

**Number of Adults in Household**

- LandLine: 0.26 Land Line Introduction
- Type: Num
- Column (fixed-width file): 69-70
- PDF page: 9
- Prologue: Variable only on the land line survey
- Description: Number of Adults in Household
- Notes: QSTVER >= 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Number of adults in the household | 96,086 | 37.74 | 20.30 |
| 2 |  | 127,367 | 50.02 | 51.79 |
| 3 |  | 22,040 | 8.66 | 16.85 |
| 4 |  | 7,013 | 2.75 | 8.01 |
| 5 |  | 1,564 | 0.61 | 2.16 |
| 6 - 99 | 6 or more | 550 | 0.22 | 0.90 |
| BLANK | Missing | 186,836 |  |  |

## NUMMEN
<a id="nummen"></a>

**Number of Adult men in Household**

- LandLine: 0.27 Land Line Introduction
- Type: Num
- Column (fixed-width file): 71-72
- PDF page: 9
- Prologue: Variable only on the land line survey
- Description: Number of Adult Men in Household
- Notes: QSTVER >= 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Number of adult men in the household | 74,653 | 29.33 | 17.33 |
| 1 |  | 159,499 | 62.67 | 64.24 |
| 2 |  | 17,262 | 6.78 | 14.43 |
| 3 |  | 2,651 | 1.04 | 3.33 |
| 4 |  | 360 | 0.14 | 0.57 |
| 5 |  | 42 | 0.02 | 0.06 |
| 6 - 99 | 6 or more | 36 | 0.01 | 0.05 |
| BLANK | Missing | 186,953 |  |  |

## NUMWOMEN
<a id="numwomen"></a>

**Number of Adult women in Household**

- LandLine: 0.28 Land Line Introduction
- Type: Num
- Column (fixed-width file): 73-74
- PDF page: 10
- Prologue: Variable only on the land line survey
- Description: Number of Adult Women in Household
- Notes: QSTVER >= 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Number of adult women in the household | 31,273 | 12.29 | 8.22 |
| 1 |  | 198,302 | 77.92 | 71.38 |
| 2 |  | 21,454 | 8.43 | 16.34 |
| 3 |  | 2,987 | 1.17 | 3.48 |
| 4 |  | 401 | 0.16 | 0.50 |
| 5 |  | 55 | 0.02 | 0.06 |
| 6 - 99 | 6 or more | 30 | 0.01 | 0.02 |
| BLANK | Missing | 186,954 |  |  |

## CTELNUM1
<a id="ctelnum1"></a>

**Correct Phone Number?**

- CellPhone: 0.29 Cell Phone Introduction
- Type: Num
- Column (fixed-width file): 75
- PDF page: 10
- Prologue: Variable only on the cell phone survey
- Description: Is this (phone number) ?
- Notes: QSTVER < = 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to CELLFON2 | 186,811 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 254,645 |  |  |

## CELLFON2
<a id="cellfon2"></a>

**Is this a cellular telephone?**

- CellPhone: 0.30 Cell Phone Introduction
- Type: Num
- Column (fixed-width file): 76
- PDF page: 10
- Prologue: Variable only on the cell phone survey
- Description: Is this a cellular telephone?
- Notes: QSTVER < 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to CADULT | 186,810 | 100.00 | 100.00 |
| 2 | No----Terminate Phone Call | 1 | 0.00 | 0.00 |
| BLANK | Not asked or Missing | 254,645 |  |  |

## CADULT
<a id="cadult"></a>

**Are you 18 years of age or older?**

- CellPhone: 0.31 Cell Phone Introduction
- Type: Num
- Column (fixed-width file): 77
- PDF page: 11
- Prologue: Variable only on the cell phone survey
- Description: Are you 18 years of age or older?
- Notes: QSTVER < 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes, Male Respondent----Go to PVTRESD2 | 92,620 | 49.58 | 53.29 |
| 2 | Yes, Female Respondent----Go to PVTRESD2 | 94,190 | 50.42 | 46.71 |
| BLANK | Not asked or Missing | 254,646 |  |  |

## PVTRESD2
<a id="pvtresd2"></a>

**Do you live in a private residence?**

- CellPhone: 0.32 Cell Phone Introduction
- Type: Num
- Column (fixed-width file): 78
- PDF page: 11
- Prologue: Variable only on the cell phone survey
- Description: Do you live in a private residence, that is, not in a dormitory or other type of group living situation?
- Notes: QSTVER < 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to CSTATE | 185,740 | 99.43 | 99.19 |
| 2 | No----Go to CCLGHOUS | 1,071 | 0.57 | 0.81 |
| BLANK | Not asked or Missing | 254,645 |  |  |

## CCLGHOUS
<a id="cclghous"></a>

**Do you live in college housing?**

- CellPhone: 0.33 Cell Phone Introduction
- Type: Num
- Column (fixed-width file): 79
- PDF page: 11
- Prologue: Variable only on the cell phone survey
- Description: Do you live in college housing?
- Notes: QSTVER < 20; or PVTRESD2=1

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to CSTATE | 1,070 | 100.00 | 100.00 |
| BLANK | Missing | 440,386 |  |  |

## CSTATE
<a id="cstate"></a>

**Are you a resident of [STATE]?**

- CellPhone: 0.34 Cell Phone Introduction
- Type: Num
- Column (fixed-width file): 80
- PDF page: 12
- Prologue: Variable only on the cell phone survey
- Description: Are you a resident of [STATE]?
- Notes: QSTVER < 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to LANDLINE | 174,380 | 93.35 | 88.69 |
| 2 | No----Go to RSPSTATE | 12,432 | 6.65 | 11.31 |
| BLANK | Not asked or Missing | 254,644 |  |  |

## LANDLINE
<a id="landline"></a>

**Do you also have a landline telephone?**

- CellPhone: 0.36 Cell Phone Introduction
- Type: Num
- Column (fixed-width file): 83
- PDF page: 12
- Prologue: Variable only on the cell phone survey
- Description: Do you also have a landline telephone in your home that is used to make and receive calls?
- Notes: QSTVER < 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 70,342 | 37.80 | 26.61 |
| 2 | No | 115,386 | 62.01 | 73.20 |
| 7 | Don’t know/Not sure | 175 | 0.09 | 0.10 |
| 9 | Refused | 164 | 0.09 | 0.10 |
| BLANK | Not asked or Missing | 255,389 |  |  |

## HHADULT
<a id="hhadult"></a>

**Number of Adults in Household**

- CellPhone: 0.37 Cell Phone Introduction
- Type: Num
- Column (fixed-width file): 84-85
- PDF page: 12
- Prologue: Variable only on the cell phone survey
- Description: How many members of your household, including yourself, are 18 years of age or older?
- Notes: QSTVER < 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 76 | Number of adults | 181,088 | 99.70 | 99.55 |
| 77 | Don’t know/Not sure | 144 | 0.08 | 0.10 |
| 99 | Refused | 399 | 0.22 | 0.35 |
| BLANK | Not asked or Missing | 259,825 |  |  |

## GENHLTH
<a id="genhlth"></a>

**General Health**

- Section: 1.1 Health Status
- Type: Num
- Column (fixed-width file): 90
- PDF page: 13
- Description: Would you say that in general your health is:

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Excellent | 76,032 | 17.22 | 18.68 |
| 2 | Very good | 145,065 | 32.86 | 31.78 |
| 3 | Good | 136,975 | 31.03 | 31.59 |
| 4 | Fair | 58,962 | 13.36 | 13.06 |
| 5 | Poor | 23,175 | 5.25 | 4.60 |
| 7 | Don’t know/Not Sure | 799 | 0.18 | 0.18 |
| 9 | Refused | 446 | 0.10 | 0.11 |
| BLANK | Not asked or Missing | 2 |  |  |

## PHYSHLTH
<a id="physhlth"></a>

**Number of Days Physical Health Not Good**

- Section: 2.1 Healthy Days — Health Related Quality of Life
- Type: Num
- Column (fixed-width file): 91-92
- PDF page: 13
- Description: Now thinking about your physical health, which includes physical illness and injury, for how many days during the past 30 days was your physical health not good?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 30 | Number of days | 157,570 | 35.69 | 35.20 |
| 88 | None | 274,143 | 62.10 | 62.77 |
| 77 | Don’t know/Not sure | 7,664 | 1.74 | 1.51 |
| 99 | Refused | 2,078 | 0.47 | 0.52 |
| BLANK | Not asked or Missing | 1 |  |  |

## MENTHLTH
<a id="menthlth"></a>

**Number of Days Mental Health Not Good**

- Section: 2.2 Healthy Days — Health Related Quality of Life
- Type: Num
- Column (fixed-width file): 93-94
- PDF page: 13
- Description: Now thinking about your mental health, which includes stress, depression, and problems with emotions, for how many days during the past 30 days was your mental health not good?
- Notes: _ _ Number of days

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 30 | Number of days | 132,972 | 30.12 | 33.58 |
| 88 | None | 301,076 | 68.20 | 64.74 |
| 77 | Don’t know/Not sure | 5,204 | 1.18 | 1.11 |
| 99 | Refused | 2,204 | 0.50 | 0.56 |

## POORHLTH
<a id="poorhlth"></a>

**Poor Physical or Mental Health**

- Section: 2.3 Healthy Days — Health Related Quality of Life
- Type: Num
- Column (fixed-width file): 95-96
- PDF page: 14
- Description: During the past 30 days, for about how many days did poor physical or mental health keep you from doing your usual activities, such as self-care, work, or recreation?
- Notes: _ _ Number of days Section 02.01, PHYSHLTH, is 88 and Section 2.02, MENTHLTH, is 88

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 30 | Number of days | 96,094 | 42.34 | 41.74 |
| 88 | None | 125,838 | 55.44 | 56.23 |
| 77 | Don’t know/Not sure | 3,782 | 1.67 | 1.43 |
| 99 | Refused | 1,250 | 0.55 | 0.59 |
| BLANK | Not asked or Missing | 214,492 |  |  |

## HLTHPLN1
<a id="hlthpln1"></a>

**Have any health care coverage**

- Section: 3.1 Health Care Access
- Type: Num
- Column (fixed-width file): 97
- PDF page: 14
- Description: Do you have any kind of health care coverage, including health insurance, prepaid plans such as HMOs, or government plans such as Medicare, or Indian Health Service?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 407,556 | 92.32 | 87.28 |
| 2 | No | 32,060 | 7.26 | 12.09 |
| 7 | Don’t know/Not Sure | 1,052 | 0.24 | 0.43 |
| 9 | Refused | 788 | 0.18 | 0.19 |

## PERSDOC2
<a id="persdoc2"></a>

**Multiple Health Care Professionals**

- Section: 3.2 Health Care Access
- Type: Num
- Column (fixed-width file): 98
- PDF page: 14
- Description: Do you have one person you think of as your personal doctor or health care provider? (If "No" ask "Is there more than one or is there no person who you think of as your personal doctor or health care provider?".)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes, only one | 341,386 | 77.33 | 70.61 |
| 2 | More than one | 34,477 | 7.81 | 7.53 |
| 3 | No | 63,737 | 14.44 | 21.30 |
| 7 | Don’t know/Not Sure | 1,165 | 0.26 | 0.37 |
| 9 | Refused | 691 | 0.16 | 0.17 |

## MEDCOST
<a id="medcost"></a>

**Could Not See Doctor Because of Cost**

- Section: 3.3 Health Care Access
- Type: Num
- Column (fixed-width file): 99
- PDF page: 15
- Description: Was there a time in the past 12 months when you needed to see a doctor but could not because of cost?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 43,514 | 9.86 | 13.22 |
| 2 | No | 396,748 | 89.87 | 86.46 |
| 7 | Don’t know/Not sure | 945 | 0.21 | 0.25 |
| 9 | Refused | 248 | 0.06 | 0.07 |
| BLANK | Not asked or Missing | 1 |  |  |

## CHECKUP1
<a id="checkup1"></a>

**Length of time since last routine checkup**

- Section: 3.4 Health Care Access
- Type: Num
- Column (fixed-width file): 100
- PDF page: 15
- Description: About how long has it been since you last visited a doctor for a routine checkup? [A routine checkup is a general physical exam, not an exam for a specific injury, illness, or condition.]

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within past year (anytime less than 12 months ago) | 325,432 | 73.72 | 69.13 |
| 2 | Within past 2 years (1 year but less than 2 years ago) | 50,529 | 11.45 | 13.10 |
| 3 | Within past 5 years (2 years but less than 5 years ago) | 28,570 | 6.47 | 8.02 |
| 4 | 5 or more years ago | 26,967 | 6.11 | 7.28 |
| 7 | Don’t know/Not sure | 5,453 | 1.24 | 1.18 |
| 8 | Never | 3,843 | 0.87 | 1.14 |
| 9 | Refused | 661 | 0.15 | 0.15 |
| BLANK | Not asked or Missing | 1 |  |  |

## BPHIGH4
<a id="bphigh4"></a>

**Ever Told Blood Pressure High**

- Section: 4.1 Hypertension Awareness
- Type: Num
- Column (fixed-width file): 101
- PDF page: 16
- Description: Have you EVER been told by a doctor, nurse or other health professional that you have high blood pressure? (If "Yes" and respondent is female, ask "Was this only when you were pregnant?".)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 178,188 | 40.36 | 31.90 |
| 2 | Yes, but female told only during pregnancy----Go to Section 05.01 BLOODCHO | 3,271 | 0.74 | 0.93 |
| 3 | No----Go to Section 05.01 BLOODCHO | 254,318 | 57.61 | 66.02 |
| 4 | Told borderline high or pre-hypertensive----Go to Section 05.01 BLOODCHO | 4,312 | 0.98 | 0.83 |
| 7 | Don´t know/Not Sure----Go to Section 05.01 BLOODCHO | 862 | 0.20 | 0.19 |
| 9 | Refused----Go to Section 05.01 BLOODCHO | 504 | 0.11 | 0.12 |
| BLANK | Not asked or Missing | 1 |  |  |

## BPMEDS
<a id="bpmeds"></a>

**Currently Taking Blood Pressure Medication**

- Section: 4.2 Hypertension Awareness
- Type: Num
- Column (fixed-width file): 102
- PDF page: 16
- Description: Are you currently taking medicine for your high blood pressure?
- Notes: Section 04.01, BPHIGH4, is coded 2, 3, 4, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 149,034 | 83.64 | 77.20 |
| 2 | No | 28,833 | 16.18 | 22.68 |
| 7 | Don’t know/Not Sure | 258 | 0.14 | 0.10 |
| 9 | Refused | 63 | 0.04 | 0.03 |
| BLANK | Not asked or Missing | 263,268 |  |  |

## BLOODCHO
<a id="bloodcho"></a>

**Ever Had Blood Cholesterol Checked**

- Section: 5.1 Cholesterol Awareness
- Type: Num
- Column (fixed-width file): 103
- PDF page: 16
- Description: Blood cholesterol is a fatty substance found in the blood. Have you EVER had your blood cholesterol checked?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 382,302 | 86.60 | 79.09 |
| 2 | No----Go to Section 06.01 CVDINFR4 | 49,673 | 11.25 | 18.04 |
| 7 | Don’t know/Not Sure----Go to Section 06.01 CVDINFR4 | 9,279 | 2.10 | 2.82 |
| 9 | Refused----Go to Section 06.01 CVDINFR4 | 202 | 0.05 | 0.04 |

## CHOLCHK
<a id="cholchk"></a>

**How Long since Cholesterol Checked**

- Section: 5.2 Cholesterol Awareness
- Type: Num
- Column (fixed-width file): 104
- PDF page: 17
- Description: About how long has it been since you last had your blood cholesterol checked?
- Notes: Section 5.01, BLOODCHO, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past year (anytime less than 12 months ago) | 293,355 | 76.73 | 73.67 |
| 2 | Within the past 2 years (1 year but less than 2 years ago) | 43,596 | 11.40 | 12.93 |
| 3 | Within the past 5 years (2 years but less than 5 years ago) | 25,972 | 6.79 | 8.01 |
| 4 | 5 or more years ago | 13,523 | 3.54 | 3.98 |
| 7 | Don’t know/Not Sure | 5,584 | 1.46 | 1.33 |
| 9 | Refused | 272 | 0.07 | 0.08 |
| BLANK | Not asked or Missing | 59,154 |  |  |

## TOLDHI2
<a id="toldhi2"></a>

**Ever Told Blood Cholesterol High**

- Section: 5.3 Cholesterol Awareness
- Type: Num
- Column (fixed-width file): 105
- PDF page: 17
- Description: Have you EVER been told by a doctor, nurse or other health professional that your blood cholesterol is high?
- Notes: Section 05.01, BLOODCHO, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 159,970 | 41.84 | 36.19 |
| 2 | No | 218,771 | 57.22 | 62.97 |
| 7 | Don’t know/Not Sure | 3,037 | 0.79 | 0.71 |
| 9 | Refused | 524 | 0.14 | 0.13 |
| BLANK | Not asked or Missing | 59,154 |  |  |

## CVDINFR4
<a id="cvdinfr4"></a>

**Ever Diagnosed with Heart Attack**

- Section: 6.1 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 106
- PDF page: 17
- Prologue: Has a doctor, nurse, or other health professional ever told you that you had any of the following? For each, tell me “Yes”, “No”, or you’re “Not sure”:
- Description: (Ever told) you had a heart attack, also called a myocardial infarction?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 25,472 | 5.77 | 4.25 |
| 2 | No | 413,755 | 93.73 | 95.30 |
| 7 | Don’t know/Not sure | 2,038 | 0.46 | 0.41 |
| 9 | Refused | 191 | 0.04 | 0.04 |

## CVDCRHD4
<a id="cvdcrhd4"></a>

**Ever Diagnosed with Angina or Coronary Heart Disease**

- Section: 6.2 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 107
- PDF page: 18
- Description: (Ever told) you had angina or coronary heart disease?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 25,290 | 5.73 | 4.04 |
| 2 | No | 412,349 | 93.41 | 95.28 |
| 7 | Don’t know/Not sure | 3,591 | 0.81 | 0.63 |
| 9 | Refused | 225 | 0.05 | 0.05 |
| BLANK | Not asked or Missing | 1 |  |  |

## CVDSTRK3
<a id="cvdstrk3"></a>

**Ever Diagnosed with a Stroke**

- Section: 6.3 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 108
- PDF page: 18
- Description: (Ever told) you had a stroke.

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 18,269 | 4.14 | 3.03 |
| 2 | No | 421,897 | 95.57 | 96.73 |
| 7 | Don’t know/Not sure | 1,146 | 0.26 | 0.21 |
| 9 | Refused | 144 | 0.03 | 0.03 |

## ASTHMA3
<a id="asthma3"></a>

**Ever Told Had Asthma**

- Section: 6.4 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 109
- PDF page: 18
- Description: (Ever told) you had asthma?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 59,409 | 13.46 | 13.80 |
| 2 | No----Go to Section 06.06 CHCSCNCR | 380,554 | 86.20 | 85.88 |
| 7 | Don’t know/Not Sure----Go to Section 06.06 CHCSCNCR | 1,336 | 0.30 | 0.28 |
| 9 | Refused----Go to Section 06.06 CHCSCNCR | 157 | 0.04 | 0.04 |

## ASTHNOW
<a id="asthnow"></a>

**Still Have Asthma**

- Section: 6.5 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 110
- PDF page: 19
- Description: Do you still have asthma?
- Notes: Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 40,000 | 67.33 | 63.58 |
| 2 | No | 17,600 | 29.63 | 33.34 |
| 7 | Don’t know/Not Sure | 1,761 | 2.96 | 2.99 |
| 9 | Refused | 48 | 0.08 | 0.09 |
| BLANK | Not asked or Missing | 382,047 |  |  |

## CHCSCNCR
<a id="chcscncr"></a>

**Ever told) you had skin cancer?**

- Section: 6.6 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 111
- PDF page: 19
- Description: (Ever told) you had skin cancer?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 41,776 | 9.46 | 5.90 |
| 2 | No | 398,420 | 90.25 | 93.88 |
| 7 | Don’t know / Not sure | 1,104 | 0.25 | 0.19 |
| 9 | Refused | 155 | 0.04 | 0.03 |
| BLANK | Not asked or Missing | 1 |  |  |

## CHCOCNCR
<a id="chcocncr"></a>

**Ever told) you had any other types of cancer?**

- Section: 6.7 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 112
- PDF page: 19
- Description: (Ever told) you had any other types of cancer?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 43,441 | 9.84 | 6.59 |
| 2 | No | 396,932 | 89.91 | 93.19 |
| 7 | Don’t know / Not sure | 888 | 0.20 | 0.17 |
| 9 | Refused | 195 | 0.04 | 0.05 |

## CHCCOPD1
<a id="chccopd1"></a>

**Ever told) you have chronic obstructive pulmonary disease, emphysema or chronic bronchitis?**

- Section: 6.8 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 113
- PDF page: 20
- Description: (Ever told) you have Chronic Obstructive Pulmonary Disease or COPD, emphysema or chronic bronchitis?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 35,501 | 8.04 | 6.24 |
| 2 | No | 403,586 | 91.42 | 93.27 |
| 7 | Don’t know / Not sure | 2,196 | 0.50 | 0.45 |
| 9 | Refused | 173 | 0.04 | 0.04 |

## HAVARTH3
<a id="havarth3"></a>

**Told Have Arthritis**

- Section: 6.9 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 114
- PDF page: 20
- Description: (Ever told) you have some form of arthritis, rheumatoid arthritis, gout, lupus, or fibromyalgia? (Arthritis diagnoses include: rheumatism, polymyalgia rheumatica; osteoarthritis (not osteporosis); tendonitis, bursitis, bunion, tennis elbow; carpal tunnel syndrome, tarsal tunnel syndrome; joint infection, etc.)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 148,036 | 33.53 | 24.53 |
| 2 | No | 290,621 | 65.83 | 74.87 |
| 7 | Don’t know/Not Sure | 2,563 | 0.58 | 0.55 |
| 9 | Refused | 235 | 0.05 | 0.06 |
| BLANK | Not asked or Missing | 1 |  |  |

## ADDEPEV2
<a id="addepev2"></a>

**Ever told you had a depressive disorder**

- Section: 6.10 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 115
- PDF page: 20
- Description: (Ever told) you that you have a depressive disorder, including depression, major depression, dysthymia, or minor depression?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 83,788 | 18.98 | 17.52 |
| 2 | No | 355,471 | 80.52 | 81.97 |
| 7 | Don’t know/Not sure | 1,659 | 0.38 | 0.38 |
| 9 | Refused | 538 | 0.12 | 0.12 |

## CHCKIDNY
<a id="chckidny"></a>

**Ever told) you have kidney disease?**

- Section: 6.11 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 116
- PDF page: 21
- Description: (Ever told) you have kidney disease? Do NOT include kidney stones, bladder infection or incontinence.(Incontinence is not being able to control urine flow.)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 15,657 | 3.55 | 2.68 |
| 2 | No | 424,222 | 96.10 | 97.00 |
| 7 | Don’t know / Not sure | 1,375 | 0.31 | 0.29 |
| 9 | Refused | 202 | 0.05 | 0.04 |

## DIABETE3
<a id="diabete3"></a>

**Ever told) you have diabetes**

- Section: 6.12 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 117
- PDF page: 21
- Description: (Ever told) you have diabetes (If "Yes" and respondent is female, ask "Was this only when you were pregnant?". If Respondent says pre-diabetes or borderline diabetes, use response code 4.)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 57,256 | 12.97 | 10.48 |
| 2 | Yes, but female told only during pregnancy----Go to Section 07.7.1 SEX | 3,608 | 0.82 | 0.95 |
| 3 | No----Go to Section 07.7.1 SEX | 372,104 | 84.29 | 86.77 |
| 4 | No, pre-diabetes or borderline diabetes----Go to Section 07.7.1 SEX | 7,690 | 1.74 | 1.60 |
| 7 | Don’t know/Not Sure----Go to Section 07.7.1 SEX | 598 | 0.14 | 0.16 |
| 9 | Refused----Go to Section 07.7.1 SEX | 193 | 0.04 | 0.04 |
| BLANK | Not asked or Missing | 7 |  |  |

## DIABAGE2
<a id="diabage2"></a>

**Age When Told Diabetic**

- Section: 6.13 Chronic Health Conditions
- Type: Num
- Column (fixed-width file): 118-119
- PDF page: 21
- Description: How old were you when you were told you have diabetes?
- Notes: _ _ Code age in years, 97 = 97 or older Section 06.12, DIABETE3, is coded 2, 3, 4, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 97 | Age in years [97 = 97 and older] | 53,356 | 93.19 | 94.18 |
| 98 | Don’t know/Not sure | 3,630 | 6.34 | 5.36 |
| 99 | Refused | 267 | 0.47 | 0.46 |
| BLANK | Not asked or Missing | 384,203 |  |  |

## SEX
<a id="sex"></a>

**Respondents Sex**

- Section: 7.1 Demographics
- Type: Num
- Column (fixed-width file): 120
- PDF page: 22
- Description: Indicate sex of respondent.

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Male | 186,938 | 42.35 | 48.68 |
| 2 | Female | 254,518 | 57.65 | 51.32 |

## MARITAL
<a id="marital"></a>

**Marital Status**

- Section: 7.6 Demographics
- Type: Num
- Column (fixed-width file): 157
- PDF page: 22
- Description: Are you: (marital status)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Married | 233,210 | 52.83 | 50.46 |
| 2 | Divorced | 59,406 | 13.46 | 10.79 |
| 3 | Widowed | 56,481 | 12.79 | 6.89 |
| 4 | Separated | 8,968 | 2.03 | 2.54 |
| 5 | Never married | 67,668 | 15.33 | 23.90 |
| 6 | A member of an unmarried couple | 12,627 | 2.86 | 4.71 |
| 9 | Refused | 3,096 | 0.70 | 0.70 |

## EDUCA
<a id="educa"></a>

**Education Level**

- Section: 7.7 Demographics
- Type: Num
- Column (fixed-width file): 158
- PDF page: 22
- Description: What is the highest grade or year of school you completed?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Never attended school or only kindergarten | 609 | 0.14 | 0.30 |
| 2 | Grades 1 through 8 (Elementary) | 11,187 | 2.53 | 4.70 |
| 3 | Grades 9 through 11 (Some high school) | 22,463 | 5.09 | 9.29 |
| 4 | Grade 12 or GED (High school graduate) | 123,227 | 27.91 | 28.19 |
| 5 | College 1 year to 3 years (Some college or technical school) | 120,528 | 27.30 | 30.88 |
| 6 | College 4 years or more (College graduate) | 161,631 | 36.61 | 26.21 |
| 9 | Refused | 1,811 | 0.41 | 0.42 |

## RENTHOM1
<a id="renthom1"></a>

**Own or Rent Home**

- Section: 7.8 Demographics
- Type: Num
- Column (fixed-width file): 159
- PDF page: 23
- Description: Do you own or rent your home? (Home is defined as the place where you live most of the time/the majority of the year.)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Own | 316,644 | 71.73 | 66.65 |
| 2 | Rent | 101,044 | 22.89 | 26.53 |
| 3 | Other arrangement | 20,625 | 4.67 | 6.01 |
| 7 | Don’t know/Not Sure | 738 | 0.17 | 0.24 |
| 9 | Refused | 2,405 | 0.54 | 0.57 |

## NUMHHOL2
<a id="numhhol2"></a>

**Household Telephones**

- Section: 7.11 Demographics
- Type: Num
- Column (fixed-width file): 168
- PDF page: 23
- Description: Do you have more than one telephone number in your household? Do not include cell phones or numbers that are only used by a computer or fax machine.
- Notes: QSTVER >= 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 13,250 | 5.20 | 4.56 |
| 2 | No----Go to Section 07.13 CPDEMO1 | 240,419 | 94.41 | 95.08 |
| 7 | Don’t know/Not sure----Go to Section 07.13 CPDEMO1 | 238 | 0.09 | 0.07 |
| 9 | Refused----Go to Section 07.13 CPDEMO1 | 738 | 0.29 | 0.29 |
| BLANK | Not asked or Missing | 186,811 |  |  |

## NUMPHON2
<a id="numphon2"></a>

**Residential Phones**

- Section: 7.12 Demographics
- Type: Num
- Column (fixed-width file): 169
- PDF page: 24
- Description: How many of these telephone numbers are residential numbers?
- Notes: 6 = 6 or more Section 07.11, NUMHHOL2, is coded 2, 7, 9, or Missing; or QSTVER >= 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Residential telephone number | 6,680 | 50.42 | 65.17 |
| 2 | Residential telephone numbers | 5,340 | 40.30 | 27.88 |
| 3 | Residential telephone numbers | 707 | 5.34 | 2.57 |
| 4 | Residential telephone numbers | 137 | 1.03 | 0.64 |
| 5 | Residential telephone numbers | 37 | 0.28 | 0.27 |
| 6 | Residential telephone numbers | 30 | 0.23 | 0.09 |
| 7 | Don’t know/Not Sure | 161 | 1.22 | 1.54 |
| 9 | Refused | 158 | 1.19 | 1.84 |
| BLANK | Not asked or Missing | 428,206 |  |  |

## CPDEMO1
<a id="cpdemo1"></a>

**Do you have a cell phone for personal use?**

- Section: 7.13 Demographics
- Type: Num
- Column (fixed-width file): 170
- PDF page: 24
- Description: Do you have a cell phone for personal use? Please include cell phones used for both business and personal use
- Notes: QSTVER > = 20

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 205,310 | 80.63 | 80.84 |
| 2 | No | 48,035 | 18.86 | 18.69 |
| 7 | Don’t know/Not sure | 169 | 0.07 | 0.05 |
| 9 | Refused | 1,131 | 0.44 | 0.43 |
| BLANK | Not asked or Missing | 186,811 |  |  |

## VETERAN3
<a id="veteran3"></a>

**Are You A Veteran**

- Section: 7.14 Demographics
- Type: Num
- Column (fixed-width file): 171
- PDF page: 25
- Description: Have you ever served on active duty in the United States Armed Forces, either in the regular military or in a National Guard or military reserve unit? (Active duty does not include training for the Reserves or National Guard, but DOES include activation, for example, for the Persian Gulf War.)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 57,842 | 13.10 | 10.81 |
| 2 | No | 382,772 | 86.71 | 89.04 |
| 7 | Don’t know/Not Sure | 166 | 0.04 | 0.03 |
| 9 | Refused | 670 | 0.15 | 0.13 |
| BLANK | Not asked or Missing | 6 |  |  |

## EMPLOY1
<a id="employ1"></a>

**Employment Status**

- Section: 7.15 Demographics
- Type: Num
- Column (fixed-width file): 172
- PDF page: 25
- Description: Are you currently…?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Employed for wages | 179,163 | 40.58 | 47.55 |
| 2 | Self-employed | 36,609 | 8.29 | 8.51 |
| 3 | Out of work for 1 year or more | 9,594 | 2.17 | 2.87 |
| 4 | Out of work for less than 1 year | 9,012 | 2.04 | 2.99 |
| 5 | A homemaker | 27,107 | 6.14 | 6.75 |
| 6 | A student | 11,551 | 2.62 | 5.72 |
| 7 | Retired | 132,648 | 30.05 | 17.75 |
| 8 | Unable to work | 31,977 | 7.24 | 6.86 |
| 9 | Refused | 3,795 | 0.86 | 1.01 |

## CHILDREN
<a id="children"></a>

**Number of Children in Household**

- Section: 7.16 Demographics
- Type: Num
- Column (fixed-width file): 173-174
- PDF page: 25
- Description: How many children less than 18 years of age live in your household?
- Notes: _ _ = Number of children

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 87 | Number of children | 113,819 | 25.78 | 36.41 |
| 88 | None | 324,000 | 73.39 | 62.57 |
| 99 | Refused | 3,632 | 0.82 | 1.02 |
| BLANK | Not asked or Missing | 5 |  |  |

## INCOME2
<a id="income2"></a>

**Income Level**

- Section: 7.17 Demographics
- Type: Num
- Column (fixed-width file): 175-176
- PDF page: 26
- Description: Is your annual household income from all sources: (If respondent refuses at any income level, code "Refused.")
- Notes: If "no," code 02 If "no," code 03; if "yes," ask 01 If "no," code 04; if "yes," ask 02 If "no," ask 05; if "yes," ask 03 If "no," ask 06 If "no," ask 07 If "no," code 08

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Less than $10,000 | 18,449 | 4.21 | 5.12 |
| 2 | Less than $15,000 ($10,000 to less than $15,000) | 19,599 | 4.47 | 4.51 |
| 3 | Less than $20,000 ($15,000 to less than $20,000) | 26,797 | 6.12 | 6.55 |
| 4 | Less than $25,000 ($20,000 to less than $25,000) | 32,377 | 7.39 | 7.65 |
| 5 | Less than $35,000 ($25,000 to less than $35,000) | 39,235 | 8.95 | 8.77 |
| 6 | Less than $50,000 ($35,000 to less than $50,000) | 52,052 | 11.88 | 11.35 |
| 7 | Less than $75,000 ($50,000 to less than $75,000) | 58,130 | 13.27 | 12.63 |
| 8 | $75,000 or more | 115,312 | 26.32 | 26.59 |
| 77 | Don’t know/Not sure | 35,258 | 8.05 | 8.88 |
| 99 | Refused | 40,946 | 9.35 | 7.95 |
| BLANK | Not asked or Missing | 3,301 |  |  |

## INTERNET
<a id="internet"></a>

**Internet use in the past 30 days?**

- Section: 7.18 Demographics
- Type: Num
- Column (fixed-width file): 177
- PDF page: 26
- Description: Have you used the internet in the past 30 days?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 343,791 | 78.64 | 81.70 |
| 2 | No | 91,959 | 21.04 | 17.84 |
| 7 | Don’t know/Not Sure | 457 | 0.10 | 0.09 |
| 9 | Refused | 939 | 0.21 | 0.37 |
| BLANK | Not asked or Missing | 4,310 |  |  |

## WEIGHT2
<a id="weight2"></a>

**Reported Weight in Pounds**

- Section: 7.19 Demographics
- Type: Num
- Column (fixed-width file): 178-181
- PDF page: 27
- Description: About how much do you weigh without shoes? (If respondent answers in metrics, put a 9 in the first column)[Round fractions up.]
- Notes: 0 _ _ _ = weight in pounds The initial ´9´ indicates this was a metric value.

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 50 - 0999 | Weight (pounds) | 409,679 | 93.93 | 94.26 |
| 7777 | Don’t know/Not sure | 7,695 | 1.76 | 1.98 |
| 9000 - 9998 | Weight (kilograms) | 862 | 0.20 | 0.37 |
| 9999 | Refused | 17,905 | 4.11 | 3.40 |
| BLANK | Not asked or Missing | 5,315 |  |  |

## HEIGHT3
<a id="height3"></a>

**Reported Height in Feet and Inches**

- Section: 7.20 Demographics
- Type: Num
- Column (fixed-width file): 182-185
- PDF page: 27
- Description: About how tall are you without shoes? (If respondent answers in metrics, put a 9 in the first column)[Round fractions down.]
- Notes: 0 _ / _ _ = feet / inches The initial '9' indicates this was a metric value.

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 200 - 711 | Height (ft/inches) | 424,202 | 97.40 | 96.34 |
| 7777 | Don’t know/Not sure | 3,776 | 0.87 | 1.39 |
| 9000 - 9998 | Height (meters/centimeters) | 1,835 | 0.42 | 0.90 |
| 9999 | Refused | 5,732 | 1.32 | 1.37 |
| BLANK | Not asked or Missing | 5,911 |  |  |

## PREGNANT
<a id="pregnant"></a>

**Pregnancy Status**

- Section: 7.21 Demographics
- Type: Num
- Column (fixed-width file): 186
- PDF page: 27
- Description: To your knowledge, are you now pregnant?
- Notes: Section 07.01, SEX, is coded 1; or Section 07.02, AGE, is greater than 44

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 2,430 | 3.74 | 4.08 |
| 2 | No | 62,027 | 95.50 | 94.87 |
| 7 | Don’t know/Not Sure | 206 | 0.32 | 0.33 |
| 9 | Refused | 289 | 0.44 | 0.72 |
| BLANK | Not asked or Missing | 376,504 |  |  |

## QLACTLM2
<a id="qlactlm2"></a>

**Activity Limitation Due to Health Problems**

- Section: 7.22 Demographics
- Type: Num
- Column (fixed-width file): 187
- PDF page: 28
- Description: Are you limited in any way in any activities because of physical, mental, or emotional problems?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 106,863 | 24.73 | 20.11 |
| 2 | No | 322,059 | 74.53 | 78.88 |
| 7 | Don’t know/Not Sure | 1,922 | 0.44 | 0.35 |
| 9 | Refused | 1,274 | 0.29 | 0.66 |
| BLANK | Not asked or Missing | 9,338 |  |  |

## USEEQUIP
<a id="useequip"></a>

**Health Problems Requiring Special Equipment**

- Section: 7.23 Demographics
- Type: Num
- Column (fixed-width file): 188
- PDF page: 28
- Description: Do you now have any health problem that requires you to use special equipment, such as a cane, a wheelchair, a special bed, or a special telephone? (Include occasional use or use in certain circumstances.)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 50,622 | 11.74 | 8.49 |
| 2 | No | 379,292 | 88.00 | 90.86 |
| 7 | Don’t know/Not Sure | 342 | 0.08 | 0.07 |
| 9 | Refused | 770 | 0.18 | 0.58 |
| BLANK | Not asked or Missing | 10,430 |  |  |

## BLIND
<a id="blind"></a>

**Blind or Difficulty seeing**

- Section: 7.24 Demographics
- Type: Num
- Column (fixed-width file): 189
- PDF page: 28
- Description: Are you blind or do you have serious difficulty seeing, even when wearing glasses?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 21,282 | 4.95 | 4.55 |
| 2 | No | 407,333 | 94.66 | 94.65 |
| 7 | Don’t know/Not Sure | 824 | 0.19 | 0.18 |
| 9 | Refused | 863 | 0.20 | 0.62 |
| BLANK | Not asked or Missing | 11,154 |  |  |

## DECIDE
<a id="decide"></a>

**Difficulty Concentrating or Remembering**

- Section: 7.25 Demographics
- Type: Num
- Column (fixed-width file): 190
- PDF page: 29
- Description: Because of a physical, mental, or emotional condition, do you have serious difficulty concentrating, remembering, or making decisions?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 42,039 | 9.78 | 10.24 |
| 2 | No | 384,762 | 89.54 | 88.74 |
| 7 | Don’t know/Not Sure | 1,883 | 0.44 | 0.34 |
| 9 | Refused | 1,032 | 0.24 | 0.68 |
| BLANK | Not asked or Missing | 11,740 |  |  |

## DIFFWALK
<a id="diffwalk"></a>

**Difficulty Walking or Climbing Stairs**

- Section: 7.26 Demographics
- Type: Num
- Column (fixed-width file): 191
- PDF page: 29
- Description: Do you have serious difficulty walking or climbing stairs?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 74,664 | 17.40 | 13.63 |
| 2 | No | 352,198 | 82.07 | 85.50 |
| 7 | Don’t know/Not Sure | 1,346 | 0.31 | 0.21 |
| 9 | Refused | 914 | 0.21 | 0.66 |
| BLANK | Not asked or Missing | 12,334 |  |  |

## DIFFDRES
<a id="diffdres"></a>

**Difficulty Dressing or Bathing**

- Section: 7.27 Demographics
- Type: Num
- Column (fixed-width file): 192
- PDF page: 29
- Description: Do you have difficulty dressing or bathing?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 18,778 | 4.38 | 3.75 |
| 2 | No | 408,765 | 95.34 | 95.50 |
| 7 | Don’t know/Not Sure | 396 | 0.09 | 0.09 |
| 9 | Refused | 789 | 0.18 | 0.66 |
| BLANK | Not asked or Missing | 12,728 |  |  |

## DIFFALON
<a id="diffalon"></a>

**Difficulty Doing Errands Alone**

- Section: 7.28 Demographics
- Type: Num
- Column (fixed-width file): 193
- PDF page: 30
- Description: Because of a physical, mental, or emotional condition, do you have difficulty doing errands alone such as visiting a doctor’s office or shopping?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 33,690 | 7.87 | 6.90 |
| 2 | No | 392,528 | 91.68 | 92.21 |
| 7 | Don’t know/Not Sure | 931 | 0.22 | 0.16 |
| 9 | Refused | 981 | 0.23 | 0.73 |
| BLANK | Not asked or Missing | 13,326 |  |  |

## SMOKE100
<a id="smoke100"></a>

**Smoked at Least 100 Cigarettes**

- Section: 8.1 Tobacco Use
- Type: Num
- Column (fixed-width file): 194
- PDF page: 30
- Description: Have you smoked at least 100 cigarettes in your entire life? [Note: 5 packs = 100 cigarettes]

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 184,299 | 43.14 | 40.67 |
| 2 | No----Go to Section 08.05 USENOW3 | 239,608 | 56.09 | 57.70 |
| 7 | Don’t know/Not Sure----Go to Section 08.05 USENOW3 | 1,832 | 0.43 | 0.35 |
| 9 | Refused----Go to Section 08.05 USENOW3 | 1,462 | 0.34 | 1.28 |
| BLANK | Not asked or Missing | 14,255 |  |  |

## SMOKDAY2
<a id="smokday2"></a>

**Frequency of Days Now Smoking**

- Section: 8.2 Tobacco Use
- Type: Num
- Column (fixed-width file): 195
- PDF page: 30
- Description: Do you now smoke cigarettes every day, some days, or not at all?
- Notes: Section 08.01, SMOKE100, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Every day | 43,583 | 23.66 | 27.77 |
| 2 | Some days | 17,998 | 9.77 | 12.67 |
| 3 | Not at all----Go to Section 08.04 LASTSMK2 | 122,277 | 66.39 | 59.37 |
| 7 | Don´t Know/Not Sure----Go to Section 08.05 USENOW3 | 86 | 0.05 | 0.05 |
| 9 | Refused----Go to Section 08.05 USENOW3 | 249 | 0.14 | 0.15 |
| BLANK | Not asked or Missing | 257,263 |  |  |

## STOPSMK2
<a id="stopsmk2"></a>

**Stopped Smoking in past 12 months**

- Section: 8.3 Tobacco Use
- Type: Num
- Column (fixed-width file): 196
- PDF page: 31
- Description: During the past 12 months, have you stopped smoking for one day or longer because you were trying to quit smoking?
- Notes: Section 08.01, SMOKE100, is coded 2, 7, 9, or Missing; or Section 08.02, SMOKDAY2, is coded 3, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to Section 08.05 USENOW3 | 34,958 | 56.83 | 60.27 |
| 2 | No----Go to Section 08.05 USENOW3 | 26,346 | 42.83 | 39.40 |
| 7 | Don’t know/Not Sure----Go to Section 08.05 USENOW3 | 180 | 0.29 | 0.26 |
| 9 | Refused----Go to Section 08.05 USENOW3 | 34 | 0.06 | 0.07 |
| BLANK | Not asked or Missing | 379,938 |  |  |

## LASTSMK2
<a id="lastsmk2"></a>

**Interval Since Last Smoked**

- Section: 8.4 Tobacco Use
- Type: Num
- Column (fixed-width file): 197-198
- PDF page: 31
- Description: How long has it been since you last smoked a cigarette, even one or two puffs?
- Notes: Section 08.01, SMOKE100, is coded 2, 7, 9, or Missing; or Section 08.02, SMOKDAY2, is coded 7, 9, or Missing; or Section 08.03, STOPSMK2, is coded 1, 2, 7, 9;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past month (less than 1 month ago) | 2,564 | 2.10 | 3.32 |
| 2 | Within the past 3 months (1 month but less than 3 months ago) | 2,348 | 1.92 | 3.14 |
| 3 | Within the past 6 months (3 months but less than 6 months ago) | 2,463 | 2.02 | 2.97 |
| 4 | Within the past year (6 months but less than 1 year ago) | 4,042 | 3.31 | 4.67 |
| 5 | Within the past 5 years (1 year but less than 5 years ago) | 15,684 | 12.84 | 17.21 |
| 6 | Within the past 10 years (5 years but less than 10 years ago) | 12,204 | 9.99 | 11.35 |
| 7 | 10 years or more | 81,153 | 66.42 | 55.84 |
| 8 | Never smoked regularly | 899 | 0.74 | 0.79 |
| 77 | Don’t know/Not sure | 706 | 0.58 | 0.59 |
| 99 | Refused | 127 | 0.10 | 0.12 |
| BLANK | Not asked or Missing | 319,266 |  |  |

## USENOW3
<a id="usenow3"></a>

**Use of Smokeless Tobacco Products**

- Section: 8.5 Tobacco Use
- Type: Num
- Column (fixed-width file): 199
- PDF page: 32
- Description: Do you currently use chewing tobacco, snuff, or snus every day, some days, or not at all? (Snus (Swedish for snuff) is a moist smokeless tobacco, usually sold in small pouches that are placed under the lip against the gum.)[Snus (rhymes with ´goose´)]

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Every day | 7,522 | 1.76 | 1.88 |
| 2 | Some days | 6,055 | 1.42 | 1.72 |
| 3 | Not at all | 411,021 | 96.36 | 94.87 |
| 7 | Don’t know/Not Sure | 143 | 0.03 | 0.06 |
| 9 | Refused | 1,825 | 0.43 | 1.47 |
| BLANK | Not asked or Missing | 14,890 |  |  |

## ALCDAY5
<a id="alcday5"></a>

**Days in past 30 had alcoholic beverage**

- Section: 9.1 Alcohol Consumption
- Type: Num
- Column (fixed-width file): 200-202
- PDF page: 32
- Description: During the past 30 days, how many days per week or per month did you have at least one drink of any alcoholic beverage such as beer, wine, a malt beverage or liquor?
- Notes: 1_ _ = Days per week 2_ _ = Days in past 30

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Days per week | 57,496 | 13.51 | 13.94 |
| 201 - 299 | Days in past 30 days | 153,850 | 36.16 | 37.36 |
| 777 | Don’t know/Not sure----Go to Section 10.01 FRUITJU1 | 3,095 | 0.73 | 0.75 |
| 888 | No drinks in past 30 days----Go to Section 10.01 FRUITJU1 | 208,460 | 48.99 | 46.56 |
| 999 | Refused----Go to Section 10.01 FRUITJU1 | 2,624 | 0.62 | 1.39 |
| BLANK | Not asked or Missing | 15,931 |  |  |

## AVEDRNK2
<a id="avedrnk2"></a>

**Avg alcoholic drinks per day in past 30**

- Section: 9.2 Alcohol Consumption
- Type: Num
- Column (fixed-width file): 203-204
- PDF page: 33
- Description: One drink is equivalent to a 12-ounce beer, a 5-ounce glass of wine, or a drink with one shot of liquor. During the past 30 days, on the days when you drank, about how many drinks did you drink on the average? (A 40 ounce beer would count as 3 drinks, or a cocktail drink with 2 shots would count as 2 drinks.)
- Notes: _ _ Number of drinks Section 09.01, ALCDAY5, is coded 888, 777, or 9999;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 76 | Number of drinks | 207,263 | 98.30 | 97.93 |
| 77 | Don’t know/Not sure | 2,826 | 1.34 | 1.69 |
| 99 | Refused | 749 | 0.36 | 0.38 |
| BLANK | Not asked or Missing | 230,618 |  |  |

## DRNK3GE5
<a id="drnk3ge5"></a>

**Binge Drinking**

- Section: 9.3 Alcohol Consumption
- Type: Num
- Column (fixed-width file): 205-206
- PDF page: 33
- Description: Considering all types of alcoholic beverages, how many times during the past 30 days did you have 5 or more drinks for men or 4 or more drinks for women on an occasion?
- Notes: Section 09.01, ALCDAY5, is coded 888, 777, or 999;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 76 | Number of Times | 50,606 | 24.05 | 30.83 |
| 88 | None | 156,779 | 74.51 | 67.42 |
| 77 | Don’t know/Not Sure | 2,374 | 1.13 | 1.36 |
| 99 | Refused | 661 | 0.31 | 0.39 |
| BLANK | Not asked or Missing | 231,036 |  |  |

## MAXDRNKS
<a id="maxdrnks"></a>

**Most drinks on single occasion past 30 days**

- Section: 9.4 Alcohol Consumption
- Type: Num
- Column (fixed-width file): 207-208
- PDF page: 33
- Description: During the past 30 days, what is the largest number of drinks you had on any occasion?
- Notes: Section 09.01, ALCDAY5, is coded 888, 777, or 999;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 76 | Number of drinks | 203,387 | 96.84 | 96.30 |
| 77 | Don’t know/Not sure | 5,514 | 2.63 | 3.04 |
| 99 | Refused | 1,116 | 0.53 | 0.67 |
| BLANK | Not asked or Missing | 231,439 |  |  |

## FRUITJU1
<a id="fruitju1"></a>

**How many times did you drink 100 percent PURE fruit juices?**

- Section: 10.1 Fruits & Vegetables
- Type: Num
- Column (fixed-width file): 209-211
- PDF page: 34
- Description: During the past month, how many times per day, week or month did you drink 100 percent PURE fruit juices? Do not include fruit-flavored drinks with added sugar or fruit juice you made at home and added sugar to. Only include 100 percent juice.

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per day | 72,140 | 17.45 | 16.06 |
| 201 - 299 | Times per week | 63,602 | 15.38 | 17.33 |
| 300 | Less than one time per month | 3,615 | 0.87 | 0.53 |
| 301 - 399 | Times per month | 97,627 | 23.61 | 23.98 |
| 555 | Never | 165,937 | 40.13 | 38.54 |
| 777 | Don’t know/Not sure | 8,229 | 1.99 | 1.91 |
| 999 | Refused | 2,308 | 0.56 | 1.64 |
| BLANK | Not asked or Missing | 27,998 |  |  |

## FRUIT1
<a id="fruit1"></a>

**How many times did you eat fruit?**

- Section: 10.2 Fruits & Vegetables
- Type: Num
- Column (fixed-width file): 212-214
- PDF page: 34
- Description: During the past month, not counting juice, how many times per day, week, or month did you eat fruit? Count fresh, frozen, or canned fruit.(Read only if necessary: “Your best guess is fine. Include apples, bananas, applesauce, oranges, grape fruit, fruit salad, watermelon, cantaloupe or musk melon, papaya, lychees, star fruit,)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per day | 183,688 | 44.55 | 42.08 |
| 201 - 299 | Times per week | 94,755 | 22.98 | 24.36 |
| 300 | Less than one time per month | 368 | 0.09 | 0.08 |
| 301 - 399 | Times per month | 109,859 | 26.65 | 26.41 |
| 555 | Never | 16,204 | 3.93 | 4.31 |
| 777 | Don’t know/Not sure | 5,139 | 1.25 | 1.08 |
| 999 | Refused | 2,293 | 0.56 | 1.68 |
| BLANK | Not asked or Missing | 29,150 |  |  |

## FVBEANS
<a id="fvbeans"></a>

**How many times did you eat beans or lentils?**

- Section: 10.3 Fruits & Vegetables
- Type: Num
- Column (fixed-width file): 215-217
- PDF page: 35
- Description: During the past month, how many times per day, week, or month did you eat cooked or canned beans, such as refried, baked, black, garbanzo beans, beans in soup, soybeans, edamame, tofu or lentils. Do NOT include long green beans.(Read only if necessary: “Include round or oval beans or peas such as navy, pinto, split peas, cow peas, garbanzo beans, lentils, soy beans and tofu. Do NOT include long green beans such as string beans, broad or winged beans, or pole beans.”)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per day | 23,825 | 5.80 | 7.26 |
| 201 - 299 | Times per week | 131,224 | 31.92 | 32.45 |
| 300 | Less than one time per month | 1,703 | 0.41 | 0.24 |
| 301 - 399 | Times per month | 176,120 | 42.84 | 40.56 |
| 555 | Never | 68,637 | 16.70 | 16.41 |
| 777 | Don’t know/Not sure | 7,386 | 1.80 | 1.40 |
| 999 | Refused | 2,186 | 0.53 | 1.67 |
| BLANK | Not asked or Missing | 30,375 |  |  |

## FVGREEN
<a id="fvgreen"></a>

**How many times did you eat dark green vegetables?**

- Section: 10.4 Fruits & Vegetables
- Type: Num
- Column (fixed-width file): 218-220
- PDF page: 35
- Description: During the past month, how many times per day, week, or month did you eat dark green vegetables for example broccoli or dark leafy greens including romaine, chard, collard greens or spinach?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per day | 78,620 | 19.17 | 19.42 |
| 201 - 299 | Times per week | 146,916 | 35.82 | 36.28 |
| 300 | Less than one time per month | 1,002 | 0.24 | 0.15 |
| 301 - 399 | Times per month | 145,551 | 35.49 | 34.12 |
| 555 | Never | 31,418 | 7.66 | 7.43 |
| 777 | Don’t know/Not sure | 4,427 | 1.08 | 0.87 |
| 999 | Refused | 2,211 | 0.54 | 1.74 |
| BLANK | Not asked or Missing | 31,311 |  |  |

## FVORANG
<a id="fvorang"></a>

**How many times did you eat orange-colored vegetables?**

- Section: 10.5 Fruits & Vegetables
- Type: Num
- Column (fixed-width file): 221-223
- PDF page: 36
- Description: During the past month, how many times per day, week, or month did you eat orange-colored vegetables such as sweet potatoes, pumpkin, winter squash, or carrots? (Read only if needed: “Winter squash have hard, thick skins and deep yellow to orange flesh. They include acorn, buttercup, and spaghetti squash.”)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per day | 28,105 | 6.87 | 6.76 |
| 201 - 299 | Times per week | 140,878 | 34.42 | 33.34 |
| 300 | Less than one time per month | 1,599 | 0.39 | 0.27 |
| 301 - 399 | Times per month | 172,208 | 42.07 | 39.97 |
| 555 | Never | 59,408 | 14.51 | 16.90 |
| 777 | Don’t know/Not sure | 4,989 | 1.22 | 1.02 |
| 999 | Refused | 2,154 | 0.53 | 1.75 |
| BLANK | Not asked or Missing | 32,115 |  |  |

## VEGETAB1
<a id="vegetab1"></a>

**How many times did you eat OTHER vegetables?**

- Section: 10.6 Fruits & Vegetables
- Type: Num
- Column (fixed-width file): 224-226
- PDF page: 36
- Description: Not counting what you just told me about, during the past month, about how many times per day, week, or month did you eat OTHER vegetables? Examples of other vegetables include tomatoes, tomato juice or V-8 juice, corn, eggplant, peas, lettuce, cabbage, and white potatoes that are not fried such as baked or mashed potatoes.(Read only if needed: “Do not count vegetables you have already counted and do not include fried potatoes.”)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per day | 132,152 | 32.36 | 29.59 |
| 201 - 299 | Times per week | 125,761 | 30.80 | 32.39 |
| 300 | Less than one time per month | 154 | 0.04 | 0.03 |
| 301 - 399 | Times per month | 134,474 | 32.93 | 32.44 |
| 555 | Never | 7,452 | 1.83 | 2.43 |
| 777 | Don’t know/Not sure | 5,795 | 1.42 | 1.19 |
| 999 | Refused | 2,530 | 0.62 | 1.93 |
| BLANK | Not asked or Missing | 33,138 |  |  |

## EXERANY2
<a id="exerany2"></a>

**Exercise in Past 30 Days**

- Section: 11.1 Exercise (Physical Activity)
- Type: Num
- Column (fixed-width file): 227
- PDF page: 37
- Description: During the past month, other than your regular job, did you participate in any physical activities or exercises such as running, calisthenics, golf, gardening, or walking for exercise?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 296,020 | 72.91 | 72.36 |
| 2 | No | 107,444 | 26.46 | 25.60 |
| 7 | Don’t know/Not Sure | 602 | 0.15 | 0.13 |
| 9 | Refused | 1,946 | 0.48 | 1.91 |
| BLANK | Not asked or Missing | 35,444 |  |  |

## EXRACT11
<a id="exract11"></a>

**Type of Physical Activity**

- Section: 11.2 Exercise (Physical Activity)
- Type: Num
- Column (fixed-width file): 228-229
- PDF page: 38
- Description: What type of physical activity or exercise did you spend the most time doing during the past month?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Active Gaming Devices (Wii Fit, Dance, Dance revolution) | 157 | 0.05 | 0.07 |
| 2 | Aerobics video or class | 7,022 | 2.37 | 1.94 |
| 3 | Backpacking | 25 | 0.01 | 0.01 |
| 4 | Badminton | 39 | 0.01 | 0.02 |
| 5 | Basketball | 1,783 | 0.60 | 1.08 |
| 6 | Bicycling machine exercise | 6,718 | 2.27 | 1.74 |
| 7 | Bicycling | 7,329 | 2.48 | 2.90 |
| 8 | Boating (Canoeing, rowing, kayaking, sailing for pleasure or camping) | 172 | 0.06 | 0.05 |
| 9 | Bowling | 608 | 0.21 | 0.18 |
| 10 | Boxing | 338 | 0.11 | 0.19 |
| 11 | Calisthenics | 4,663 | 1.58 | 1.86 |
| 12 | Canoeing/rowing in competition | 98 | 0.03 | 0.03 |
| 13 | Carpentry | 159 | 0.05 | 0.05 |
| 14 | Dancing-ballet, ballroom, Latin, hip hop, etc | 2,018 | 0.68 | 0.85 |
| 15 | Elliptical/EFX machine exercise | 4,836 | 1.64 | 1.64 |
| 16 | Fishing from river bank or boat | 242 | 0.08 | 0.07 |
| 17 | Frisbee | 89 | 0.03 | 0.04 |
| 18 | Gardening (spading, weeding, digging, filling) | 16,266 | 5.50 | 4.10 |
| 19 | Golf (with motorized cart) | 3,681 | 1.24 | 1.09 |
| 20 | Golf (without motorized cart) | 1,645 | 0.56 | 0.49 |
| 21 | Handball | 33 | 0.01 | 0.02 |
| 22 | Hiking - cross-country | 2,757 | 0.93 | 1.04 |
| 23 | Hockey | 277 | 0.09 | 0.11 |
| 24 | Horseback riding | 468 | 0.16 | 0.15 |
| 25 | Hunting large game - deer, elk | 240 | 0.08 | 0.06 |
| 26 | Hunting small game - quail | 148 | 0.05 | 0.04 |
| 27 | Inline Skating | 20 | 0.01 | 0.01 |
| 28 | Jogging | 2,774 | 0.94 | 1.42 |
| 29 | Lacrosse | 23 | 0.01 | 0.01 |
| 30 | Mountain climbing | 62 | 0.02 | 0.02 |
| 31 | Mowing lawn | 1,202 | 0.41 | 0.32 |
| 32 | Paddleball | 30 | 0.01 | 0.01 |
| 33 | Painting/papering house | 67 | 0.02 | 0.02 |
| 34 | Pilates | 586 | 0.20 | 0.20 |
| 35 | Racquetball | 246 | 0.08 | 0.10 |
| 36 | Raking lawn | 168 | 0.06 | 0.04 |
| 37 | Running | 19,638 | 6.64 | 10.80 |
| 38 | Rock Climbing | 168 | 0.06 | 0.08 |
| 39 | Rope skipping | 43 | 0.01 | 0.03 |
| 40 | Rowing machine exercise | 277 | 0.09 | 0.09 |
| 41 | Rugby | 26 | 0.01 | 0.02 |
| 42 | Scuba diving | 22 | 0.01 | 0.01 |
| 43 | Skateboarding | 138 | 0.05 | 0.11 |
| 44 | Skating - ice or roller | 144 | 0.05 | 0.06 |
| 45 | Sledding, tobogganing | 19 | 0.01 | 0.01 |
| 46 | Snorkeling | 27 | 0.01 | 0.01 |
| 47 | Snow blowing | 80 | 0.03 | 0.02 |
| 48 | Snow shoveling by hand | 865 | 0.29 | 0.19 |
| 49 | Snow skiing | 553 | 0.19 | 0.12 |
| 50 | Snowshoeing | 111 | 0.04 | 0.02 |
| 51 | Soccer | 889 | 0.30 | 0.68 |
| 52 | Softball/Baseball | 504 | 0.17 | 0.25 |
| 53 | Squash | 36 | 0.01 | 0.01 |
| 54 | Stair climbing/Stair master | 933 | 0.32 | 0.29 |
| 55 | Stream fishing in waders | 10 | 0.00 | 0.00 |
| 56 | Surfing | 126 | 0.04 | 0.04 |
| 57 | Swimming | 2,781 | 0.94 | 0.91 |
| 58 | Swimming in laps | 1,556 | 0.53 | 0.47 |
| 59 | Table tennis | 40 | 0.01 | 0.02 |
| 60 | Tai Chi | 288 | 0.10 | 0.05 |
| 61 | Tennis | 1,163 | 0.39 | 0.39 |
| 62 | Touch football | 110 | 0.04 | 0.09 |
| 63 | Volleyball | 439 | 0.15 | 0.22 |
| 64 | Walking | 161,359 | 54.55 | 49.75 |
| 66 | Waterskiing | 103 | 0.03 | 0.03 |
| 67 | Weight lifting | 10,926 | 3.69 | 5.47 |
| 68 | Wrestling | 97 | 0.03 | 0.04 |
| 69 | Yoga | 2,916 | 0.99 | 0.99 |
| 71 | Childcare | 524 | 0.18 | 0.20 |
| 72 | Farm/Ranch Work (caring for livestock, stacking hay, etc.) | 1,093 | 0.37 | 0.25 |
| 73 | Household Activities (vacuuming, dusting, home repair, etc.) | 2,023 | 0.68 | 0.48 |
| 74 | Karate/Martial Arts | 469 | 0.16 | 0.24 |
| 75 | Upper Body Cycle (wheelchair sports, ergometer, etc.) | 201 | 0.07 | 0.07 |
| 76 | Yard work (cutting/gathering wood, trimming hedges, etc.) | 4,845 | 1.64 | 1.27 |
| 98 | Other______ | 12,033 | 4.07 | 3.90 |
| 77 | Don’t know/Not Sure----Go to Section 11.08 STRENGTH | 800 | 0.27 | 0.24 |
| 99 | Refused----Go to Section 11.08 STRENGTH | 414 | 0.14 | 0.15 |
| BLANK | Not asked or Missing | 145,678 |  |  |

## EXEROFT1
<a id="exeroft1"></a>

**How Many Times Walking, Running, Jogging, or Swimming**

- Section: 11.3 Exercise (Physical Activity)
- Type: Num
- Column (fixed-width file): 230-232
- PDF page: 40
- Description: How many times per week or per month did you take part in this activity during the past month?
- Notes: Section 11.01, EXERANY2, is coded 2, 7, 9, or Missing; or Section 11.02, EXRACT11 is coded 77, 99

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per week | 207,513 | 70.58 | 71.24 |
| 201 - 299 | Times per month | 83,652 | 28.45 | 27.93 |
| 777 | Don’t know/Not sure | 2,275 | 0.77 | 0.62 |
| 999 | Refused | 585 | 0.20 | 0.21 |
| BLANK | Not asked or Missing | 147,431 |  |  |

## EXERHMM1
<a id="exerhmm1"></a>

**Minutes or Hours Walking, Running, Jogging, or Swimming**

- Section: 11.4 Exercise (Physical Activity)
- Type: Num
- Column (fixed-width file): 233-235
- PDF page: 40
- Description: And when you took part in this activity, for how many minutes or hours did you usually keep at it?
- Notes: Section 11.01, EXERANY2, is coded 2, 7, 9, or Missing; or Section 11.02, EXRACT11 is coded 77, 99

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 759 | Hours and Minutes | 286,352 | 97.51 | 97.98 |
| 777 | Don’t know/Not sure | 5,520 | 1.88 | 1.42 |
| 800 - 959 | Hours and Minutes | 1,364 | 0.46 | 0.45 |
| 999 | Refused | 429 | 0.15 | 0.15 |
| BLANK | Not asked or Missing | 147,791 |  |  |

## EXRACT21
<a id="exract21"></a>

**Other Type of Physical Activity Giving Most Exercise During Past Month**

- Section: 11.5 Exercise (Physical Activity)
- Type: Num
- Column (fixed-width file): 236-237
- PDF page: 41
- Description: What other type of physical activity gave you the next most exercise during the past month?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Active Gaming Devices (Wii Fit, Dance, Dance revolution) | 214 | 0.07 | 0.07 |
| 2 | Aerobics video or class | 4,643 | 1.58 | 1.40 |
| 3 | Backpacking | 21 | 0.01 | 0.01 |
| 4 | Badminton | 66 | 0.02 | 0.04 |
| 5 | Basketball | 1,988 | 0.68 | 1.14 |
| 6 | Bicycling machine exercise | 5,904 | 2.01 | 1.71 |
| 7 | Bicycling | 8,074 | 2.75 | 2.96 |
| 8 | Boating (Canoeing, rowing, kayaking, sailing for pleasure or camping) | 390 | 0.13 | 0.11 |
| 9 | Bowling | 884 | 0.30 | 0.23 |
| 10 | Boxing | 270 | 0.09 | 0.16 |
| 11 | Calisthenics | 5,471 | 1.87 | 2.19 |
| 12 | Canoeing/rowing in competition | 150 | 0.05 | 0.05 |
| 13 | Carpentry | 395 | 0.13 | 0.09 |
| 14 | Dancing-ballet, ballroom, Latin, hip hop, etc | 2,591 | 0.88 | 1.04 |
| 15 | Elliptical/EFX machine exercise | 3,481 | 1.19 | 1.18 |
| 16 | Fishing from river bank or boat | 727 | 0.25 | 0.22 |
| 17 | Frisbee | 123 | 0.04 | 0.06 |
| 18 | Gardening (spading, weeding, digging, filling) | 13,680 | 4.66 | 3.59 |
| 19 | Golf (with motorized cart) | 2,731 | 0.93 | 0.79 |
| 20 | Golf (without motorized cart) | 1,638 | 0.56 | 0.48 |
| 21 | Handball | 28 | 0.01 | 0.01 |
| 22 | Hiking - cross-country | 2,647 | 0.90 | 0.93 |
| 23 | Hockey | 171 | 0.06 | 0.07 |
| 24 | Horseback riding | 625 | 0.21 | 0.16 |
| 25 | Hunting large game - deer, elk | 259 | 0.09 | 0.08 |
| 26 | Hunting small game - quail | 194 | 0.07 | 0.05 |
| 27 | Inline Skating | 22 | 0.01 | 0.01 |
| 28 | Jogging | 1,852 | 0.63 | 0.93 |
| 29 | Lacrosse | 15 | 0.01 | 0.01 |
| 30 | Mountain climbing | 75 | 0.03 | 0.03 |
| 31 | Mowing lawn | 2,332 | 0.80 | 0.55 |
| 32 | Paddleball | 26 | 0.01 | 0.01 |
| 33 | Painting/papering house | 190 | 0.06 | 0.05 |
| 34 | Pilates | 881 | 0.30 | 0.28 |
| 35 | Racquetball | 181 | 0.06 | 0.07 |
| 36 | Raking lawn | 286 | 0.10 | 0.08 |
| 37 | Running | 8,875 | 3.03 | 4.94 |
| 38 | Rock Climbing | 161 | 0.05 | 0.09 |
| 39 | Rope skipping | 104 | 0.04 | 0.06 |
| 40 | Rowing machine exercise | 387 | 0.13 | 0.12 |
| 41 | Rugby | 22 | 0.01 | 0.01 |
| 42 | Scuba diving | 25 | 0.01 | 0.02 |
| 43 | Skateboarding | 107 | 0.04 | 0.08 |
| 44 | Skating - ice or roller | 162 | 0.06 | 0.07 |
| 45 | Sledding, tobogganing | 39 | 0.01 | 0.02 |
| 46 | Snorkeling | 27 | 0.01 | 0.00 |
| 47 | Snow blowing | 149 | 0.05 | 0.03 |
| 48 | Snow shoveling by hand | 1,653 | 0.56 | 0.35 |
| 49 | Snow skiing | 631 | 0.22 | 0.15 |
| 50 | Snowshoeing | 170 | 0.06 | 0.02 |
| 51 | Soccer | 799 | 0.27 | 0.59 |
| 52 | Softball/Baseball | 605 | 0.21 | 0.31 |
| 53 | Squash | 53 | 0.02 | 0.03 |
| 54 | Stair climbing/Stair master | 3,103 | 1.06 | 0.85 |
| 55 | Stream fishing in waders | 22 | 0.01 | 0.01 |
| 56 | Surfing | 132 | 0.05 | 0.05 |
| 57 | Swimming | 4,453 | 1.52 | 1.67 |
| 58 | Swimming in laps | 1,599 | 0.55 | 0.55 |
| 59 | Table tennis | 61 | 0.02 | 0.04 |
| 60 | Tai Chi | 365 | 0.12 | 0.09 |
| 61 | Tennis | 1,037 | 0.35 | 0.37 |
| 62 | Touch football | 119 | 0.04 | 0.10 |
| 63 | Volleyball | 528 | 0.18 | 0.26 |
| 64 | Walking | 40,852 | 13.93 | 12.81 |
| 66 | Waterskiing | 65 | 0.02 | 0.02 |
| 67 | Weight lifting | 18,218 | 6.21 | 7.73 |
| 68 | Wrestling | 105 | 0.04 | 0.05 |
| 69 | Yoga | 5,004 | 1.71 | 1.67 |
| 71 | Childcare | 2,456 | 0.84 | 0.89 |
| 72 | Farm/Ranch Work (caring for livestock, stacking hay, etc.) | 1,770 | 0.60 | 0.36 |
| 73 | Household Activities (vacuuming, dusting, home repair, etc.) | 14,388 | 4.91 | 3.42 |
| 74 | Karate/Martial Arts | 296 | 0.10 | 0.14 |
| 75 | Upper Body Cycle (wheelchair sports, ergometer, etc.) | 294 | 0.10 | 0.13 |
| 76 | Yard work (cutting/gathering wood, trimming hedges, etc.) | 10,110 | 3.45 | 2.57 |
| 88 | No other activity----Go to Section 11.08 STRENGTH | 92,337 | 31.48 | 32.27 |
| 98 | Other______ | 15,106 | 5.15 | 4.97 |
| 77 | Don’t know/Not Sure----Go to Section 11.08 STRENGTH | 2,805 | 0.96 | 0.93 |
| 99 | Refused----Go to Section 11.08 STRENGTH | 861 | 0.29 | 0.34 |
| BLANK | Not asked or Missing | 148,176 |  |  |

## EXEROFT2
<a id="exeroft2"></a>

**How Many Times Walking, Running, Jogging, or Swimming**

- Section: 11.6 Exercise (Physical Activity)
- Type: Num
- Column (fixed-width file): 238-240
- PDF page: 43
- Description: How many times per week or per month did you take part in this activity during the past month?
- Notes: Section 11.01, EXERANY2, is coded 2, 7, 9, or Missing; or Section 11.02, EXRACT11 is coded 77, 99 or Section 11.05, EXRACT21 is coded 77, 88, 99

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per week | 129,532 | 65.78 | 66.10 |
| 201 - 299 | Times per month | 65,164 | 33.09 | 32.98 |
| 777 | Don’t know/Not sure | 1,810 | 0.92 | 0.74 |
| 999 | Refused | 410 | 0.21 | 0.18 |
| BLANK | Not asked or Missing | 244,540 |  |  |

## EXERHMM2
<a id="exerhmm2"></a>

**Minutes or Hours Walking, Running, Jogging, or Swimming**

- Section: 11.7 Exercise (Physical Activity)
- Type: Num
- Column (fixed-width file): 241-243
- PDF page: 43
- Description: And when you took part in this activity, for how many minutes or hours did you usually keep at it?
- Notes: Section 11.01, EXERANY2, is coded 2, 7, 9, or Missing; or Section 11.02, EXRACT11 is coded 77, 99 or Section 11.05, EXRACT21 is coded 77, 88, 99

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 759 | Hours and Minutes | 190,750 | 96.96 | 97.50 |
| 777 | Don’t know/Not sure | 3,975 | 2.02 | 1.49 |
| 800 - 959 | Hours and Minutes | 1,577 | 0.80 | 0.80 |
| 999 | Refused | 432 | 0.22 | 0.22 |
| BLANK | Not asked or Missing | 244,722 |  |  |

## STRENGTH
<a id="strength"></a>

**How many times did you do physical activities or exercises to STRENGTHEN your muscles?**

- Section: 11.8 Exercise (Physical Activity)
- Type: Num
- Column (fixed-width file): 244-246
- PDF page: 44
- Description: During the past month, how many times per week or per month did you do physical activities or exercises to STRENGTHEN your muscles? [Do NOT count aerobic activities like walking, running, or bicycling. Count activities using your own body weight like yoga, sit-ups or push-ups and those using weight machines, free weights, or elastic bands.]

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per week | 102,751 | 25.51 | 27.55 |
| 201 - 299 | Times per month | 50,324 | 12.50 | 13.45 |
| 777 | Don’t know / Not sure | 2,788 | 0.69 | 0.60 |
| 888 | Never | 244,368 | 60.68 | 56.25 |
| 999 | Refused | 2,505 | 0.62 | 2.15 |
| BLANK | Not asked or Missing | 38,720 |  |  |

## LMTJOIN3
<a id="lmtjoin3"></a>

**Limited Because of Joint Symptoms**

- Section: 12.1 Arthritis Burden
- Type: Num
- Column (fixed-width file): 247
- PDF page: 44
- Prologue: Arthritis can cause symptoms like pain, aching, or stiffness in or around a joint.
- Description: Are you now limited in any way in any of your usual activities because of arthritis or joint symptoms?
- Notes: Section 06.09, HAVARTH3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 67,129 | 49.11 | 49.15 |
| 2 | No | 67,911 | 49.68 | 48.87 |
| 7 | Don’t know/Not sure | 1,153 | 0.84 | 0.71 |
| 9 | Refused | 497 | 0.36 | 1.27 |
| BLANK | Not asked or Missing | 304,766 |  |  |

## ARTHDIS2
<a id="arthdis2"></a>

**Does Arthritis Affect Whether You Work**

- Section: 12.2 Arthritis Burden
- Type: Num
- Column (fixed-width file): 248
- PDF page: 44
- Prologue: In this next question we are referring to work for pay.
- Description: Do arthritis or joint symptoms now affect whether you work, the type of work you do or the amount of work you do?
- Notes: Section 06.09, HAVARTH3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 42,362 | 31.03 | 34.28 |
| 2 | No | 90,058 | 65.98 | 62.33 |
| 7 | Don’t know/Not Sure | 2,484 | 1.82 | 1.49 |
| 9 | Refused | 1,599 | 1.17 | 1.90 |
| BLANK | Missing | 304,953 |  |  |

## ARTHSOCL
<a id="arthsocl"></a>

**Social Activities Limited Because of Joint Symptoms**

- Section: 12.3 Arthritis Burden
- Type: Num
- Column (fixed-width file): 249
- PDF page: 45
- Description: During the past 30 days, to what extent has your arthritis or joint symptoms interfered with your normal social activities, such as going shopping, to the movies, or to religious or social gatherings?
- Notes: Section 06.09, HAVARTH3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | A lot | 24,937 | 18.30 | 19.82 |
| 2 | A little | 32,422 | 23.79 | 24.79 |
| 3 | Not at all | 77,678 | 56.99 | 53.61 |
| 7 | Don’t know/Not Sure | 671 | 0.49 | 0.43 |
| 9 | Refused | 586 | 0.43 | 1.36 |
| BLANK | Missing | 305,162 |  |  |

## JOINPAIN
<a id="joinpain"></a>

**How Bad Was Joint Pain**

- Section: 12.4 Arthritis Burden
- Type: Num
- Column (fixed-width file): 250-251
- PDF page: 45
- Description: Please think about the past 30 days, keeping in mind all of your joint pain or aching and whether or not you have taken medication. DURING THE PAST 30 DAYS, how bad was your joint pain ON AVERAGE? [Please answer on a scale of 0 to 10 where 0 is no pain or aching and 10 is pain or aching as bad as it can be.]
- Notes: Section 06.09, HAVARTH3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 10 | Enter number [0-10] | 131,077 | 98.02 | 97.53 |
| 77 | Don’t know/Not Sure | 1,891 | 1.41 | 1.12 |
| 99 | Refused | 760 | 0.57 | 1.35 |
| BLANK | Missing | 307,728 |  |  |

## SEATBELT
<a id="seatbelt"></a>

**How often use seatbelts in car?**

- Section: 13.1 Seatbelt Use
- Type: Num
- Column (fixed-width file): 252
- PDF page: 46
- Description: How often do you use seat belts when you drive or ride in a car? Would you say—
- Notes: Value should be unique for a state for a year. Due to the nature of the data or the size of the table for display, this data is not printed for this report

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Always | 348,569 | 86.93 | 86.00 |
| 2 | Nearly always | 27,549 | 6.87 | 6.04 |
| 3 | Sometimes | 10,971 | 2.74 | 2.82 |
| 4 | Seldom | 4,530 | 1.13 | 1.08 |
| 5 | Never | 6,166 | 1.54 | 1.63 |
| 7 | Don’t know/Not sure | 253 | 0.06 | 0.06 |
| 8 | Never drive or ride in a car | 875 | 0.22 | 0.25 |
| 9 | Refused | 2,076 | 0.52 | 2.11 |
| BLANK | Not asked or Missing | 40,467 |  |  |

## FLUSHOT6
<a id="flushot6"></a>

**Adult flu shot/spray past 12 mos**

- Section: 14.1 Immunization
- Type: Num
- Column (fixed-width file): 253
- PDF page: 46
- Prologue: Now I will ask you questions about the flu vaccine. There are two ways to get the flu vaccine, one is a shot in the arm and the other is a spray, mist, or drop in the nose called FluMist™.
- Description: During the past 12 months, have you had either a flu shot or a flu vaccine that was sprayed in your nose? (A new flu shot came out in 2011 that injects vaccine into the skin with a very small needle. It is called Fluzone Intradermal vaccine. This is also considered a flu shot.)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 191,438 | 47.85 | 39.25 |
| 2 | No----Go to Section 14.04 PNEUVAC3 | 205,571 | 51.38 | 58.25 |
| 7 | Don’t know/Not Sure----Go to Section 14.04 PNEUVAC3 | 965 | 0.24 | 0.32 |
| 9 | Refused----Go to Section 14.04 PNEUVAC3 | 2,101 | 0.53 | 2.18 |
| BLANK | Not asked or Missing | 41,381 |  |  |

## FLSHTMY2
<a id="flshtmy2"></a>

**When did you (adult) receive your most recent seasonal flu shot/spray?**

- Section: 14.2 Immunization
- Type: Num
- Column (fixed-width file): 254-259
- PDF page: 47
- Description: During what month and year did you receive your most recent flu shot injected into your arm or flu vaccine that was sprayed in your nose?
- Notes: Section 14.01, FLUSHOT6, is coded 2, 7, or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 12014 - 122015 | Month / Year | 178,926 | 94.08 | 93.03 |
| 777777 | Don’t know/Not Sure | 10,944 | 5.75 | 6.72 |
| 999999 | Refused | 324 | 0.17 | 0.25 |
| BLANK | Not asked or Missing | 251,262 |  |  |

## IMFVPLAC
<a id="imfvplac"></a>

**Where did you get your last flu shot/vaccine?**

- Section: 14.3 Immunization
- Type: Num
- Column (fixed-width file): 260-261
- PDF page: 47
- Description: At what kind of place did you get your last flu shot/vaccine?
- Notes: Section 14.01, FLUSHOT6, is coded 2, 7, or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | A doctor´s office or health maintenance organization (HMO) | 72,670 | 38.01 | 38.56 |
| 2 | A health department | 4,423 | 2.31 | 1.85 |
| 3 | Another type of clinic or health center (Example: a community health center) | 17,619 | 9.22 | 9.02 |
| 4 | A senior, recreation, or community center | 2,190 | 1.15 | 0.71 |
| 5 | A store (Examples: supermarket, drug store) | 48,541 | 25.39 | 22.56 |
| 6 | A hospital (Example: inpatient) | 11,043 | 5.78 | 7.15 |
| 7 | An emergency room | 130 | 0.07 | 0.08 |
| 8 | Workplace | 26,666 | 13.95 | 15.59 |
| 9 | Some other kind of place | 5,780 | 3.02 | 3.03 |
| 10 | Received vaccination in Canada/Mexico (Volunteered - Do not read) | 80 | 0.04 | 0.06 |
| 11 | A school | 1,376 | 0.72 | 0.92 |
| 77 | Don’t know / Not sure----Probe: | 562 | 0.29 | 0.36 |
| 99 | Refused | 119 | 0.06 | 0.11 |
| BLANK | Not asked or Missing | 250,257 |  |  |

## PNEUVAC3
<a id="pneuvac3"></a>

**Pneumonia shot ever**

- Section: 14.4 Immunization
- Type: Num
- Column (fixed-width file): 262
- PDF page: 48
- Description: A pneumonia shot or pneumococcal vaccine is usually given only once or twice in a person´s lifetime and is different from the flu shot. Have you ever had a pneumonia shot?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 157,698 | 39.47 | 30.02 |
| 2 | No | 205,590 | 51.46 | 56.42 |
| 7 | Don’t know/Not Sure | 34,121 | 8.54 | 11.36 |
| 9 | Refused | 2,104 | 0.53 | 2.20 |
| BLANK | Not asked or Missing | 41,943 |  |  |

## HIVTST6
<a id="hivtst6"></a>

**Ever tested HIV**

- Section: 15.1 HIV/AIDS
- Type: Num
- Column (fixed-width file): 263
- PDF page: 48
- Description: Have you ever been tested for HIV? Do not count tests you may have had as part of a blood donation. Include testing fluid from your mouth.

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 113,779 | 28.58 | 36.10 |
| 2 | No----Go to optional modules or closing statement | 269,733 | 67.76 | 58.97 |
| 7 | Don’t know/Not Sure----Go to optional modules or closing statement | 11,562 | 2.90 | 2.45 |
| 9 | Refused----Go to optional modules or closing statement | 2,995 | 0.75 | 2.48 |
| BLANK | Not asked or Missing | 43,387 |  |  |

## HIVTSTD3
<a id="hivtstd3"></a>

**Month and Year of Last HIV Test**

- Section: 15.2 HIV/AIDS
- Type: Num
- Column (fixed-width file): 264-269
- PDF page: 48
- Description: Not including blood donations, in what month and year was your last HIV test? (If response is before January 1985, code "777777".)
- Notes: _ _/_ _ _ _ month and year Section 15.01, HIVTST6, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 11985 - 122016 | Code month and year | 89,576 | 78.79 | 81.52 |
| 777777 | Don’t know/Not sure | 23,677 | 20.83 | 18.09 |
| 999999 | Refused | 439 | 0.39 | 0.39 |
| BLANK | Not asked or Missing | 327,764 |  |  |

## WHRTST10
<a id="whrtst10"></a>

**Location of last HIV test**

- Section: 15.3 HIV/AIDS
- Type: Num
- Column (fixed-width file): 270-271
- PDF page: 49
- Description: Where did you have your last HIV test — at a private doctor or HMO office, at a counseling and testing site, in the emergency room, as an inpatient in a hospital, at a clinic, in a jail or prison, at a drug treatment facility, at home, or somewhere else?
- Notes: Section 15.01, HIVTST6, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Private doctor or HMO | 52,062 | 45.86 | 46.66 |
| 2 | Counseling and testing site | 4,023 | 3.54 | 3.68 |
| 3 | Hospital inpatient | 10,716 | 9.44 | 8.66 |
| 4 | Clinic | 24,303 | 21.41 | 22.90 |
| 5 | Jail or prison (or other correctional facility) | 1,215 | 1.07 | 1.48 |
| 6 | Drug treatment facility | 519 | 0.46 | 0.49 |
| 7 | At home | 2,811 | 2.48 | 2.02 |
| 8 | Somewhere else | 13,639 | 12.01 | 10.61 |
| 9 | Emergency room | 1,974 | 1.74 | 1.85 |
| 77 | Don’t know/Not sure | 1,991 | 1.75 | 1.38 |
| 99 | Refused | 265 | 0.23 | 0.26 |
| BLANK | Not asked or Missing | 327,938 |  |  |

## PDIABTST
<a id="pdiabtst"></a>

**Had a test for high blood sugar or diabetes in the past three years?**

- Module: 1.1 Pre-Diabetes
- Type: Num
- Column (fixed-width file): 287
- PDF page: 49
- Description: Have you had a test for high blood sugar or diabetes within the past three years?
- Notes: Section 06.12, DIABETE3, is coded 1

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 50,705 | 61.27 | 54.66 |
| 2 | No | 28,188 | 34.06 | 40.66 |
| 7 | Don’t know/Not Sure | 3,826 | 4.62 | 4.62 |
| 9 | Refused | 41 | 0.05 | 0.05 |
| BLANK | Not asked or Missing | 358,696 |  |  |

## PREDIAB1
<a id="prediab1"></a>

**Ever been told by a doctor or other health professional that you have pre-diabetes or borderline diabetes?**

- Module: 1.2 Pre-Diabetes
- Type: Num
- Column (fixed-width file): 288
- PDF page: 50
- Description: Have you ever been told by a doctor or other health professional that you have pre-diabetes or borderline diabetes? (If “Yes” and respondent is female, ask: “Was this only when you were pregnant?”)
- Notes: Section 06.12, DIABETE3, is coded 1; If Section 06.12, DIABETE3, is coded 4 automatically code Module 01.02, PREDIAB1, equal to 1 (yes);

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 8,550 | 10.33 | 8.37 |
| 2 | Yes, during pregnancy | 982 | 1.19 | 1.25 |
| 3 | No | 72,890 | 88.07 | 89.95 |
| 7 | Don’t know/Not Sure | 291 | 0.35 | 0.38 |
| 9 | Refused | 47 | 0.06 | 0.05 |
| BLANK | Not asked or Missing | 358,696 |  |  |

## INSULIN
<a id="insulin"></a>

**Now Taking Insulin**

- Module: 2.1 Diabetes
- Type: Num
- Column (fixed-width file): 289
- PDF page: 50
- Description: Are you now taking insulin?
- Notes: Section 06.12, DIABETE3, is coded 2, 3, 4, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 9,602 | 32.63 | 32.36 |
| 2 | No | 19,788 | 67.25 | 67.55 |
| 9 | Refused | 34 | 0.12 | 0.09 |
| BLANK | Not asked or Missing | 412,032 |  |  |

## BLDSUGAR
<a id="bldsugar"></a>

**How Often Check Blood for Glucose**

- Module: 2.2 Diabetes
- Type: Num
- Column (fixed-width file): 290-292
- PDF page: 51
- Description: About how often do you check your blood for glucose or sugar? Include times when checked by a family member or friend, but do NOT include times when checked by a health professional.
- Notes: 1 _ _ Times per day 2 _ _ Times per week 3 _ _ Times per month 4 _ _ Times per year Section 06.12, DIABETE3, is coded 2, 3, 4, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per day | 17,883 | 60.78 | 60.47 |
| 201 - 299 | Times per week | 4,734 | 16.09 | 16.40 |
| 301 - 399 | Times per month | 1,616 | 5.49 | 5.87 |
| 401 - 499 | Times per year | 717 | 2.44 | 2.36 |
| 777 | Don’t know/Not sure | 436 | 1.48 | 1.67 |
| 888 | Never | 3,954 | 13.44 | 12.96 |
| 999 | Refused | 83 | 0.28 | 0.27 |
| BLANK | Not asked or Missing | 412,033 |  |  |

## FEETCHK2
<a id="feetchk2"></a>

**How Often Check Feet for Sores or Irritations**

- Module: 2.3 Diabetes
- Type: Num
- Column (fixed-width file): 293-295
- PDF page: 51
- Description: About how often do you check your feet for any sores or irritations? Include times when checked by a family member or friend, but do NOT include times when checked by a health professional.
- Notes: 1 _ _ Times per day 2 _ _ Times per week 3 _ _ Times per month 4 _ _ Times per year Section 06.12, DIABETE3, is coded 2, 3, 4, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Times per day | 17,076 | 58.04 | 57.71 |
| 201 - 299 | Times per week | 4,912 | 16.70 | 16.03 |
| 301 - 399 | Times per month | 1,624 | 5.52 | 5.85 |
| 401 - 499 | Times per year | 481 | 1.63 | 1.51 |
| 555 | No feet | 278 | 0.94 | 0.87 |
| 777 | Don’t know/Not sure | 763 | 2.59 | 2.43 |
| 888 | Never | 4,175 | 14.19 | 15.24 |
| 999 | Refused | 112 | 0.38 | 0.37 |
| BLANK | Not asked or Missing | 412,035 |  |  |

## DOCTDIAB
<a id="doctdiab"></a>

**Times Seen Health Professional for Diabetes**

- Module: 2.4 Diabetes
- Type: Num
- Column (fixed-width file): 296-297
- PDF page: 52
- Description: About how many times in the past 12 months have you seen a doctor, nurse, or other health professional for your diabetes?
- Notes: _ _ Number of times, 76=76 or more Section 06.12, DIABETE3, is coded 2, 3, 4, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 76 | Number of times [76=76 or more] | 25,414 | 86.39 | 86.50 |
| 88 | None | 2,895 | 9.84 | 9.93 |
| 77 | Don’t know/Not sure | 993 | 3.38 | 3.14 |
| 99 | Refused | 116 | 0.39 | 0.44 |
| BLANK | Not asked or Missing | 412,038 |  |  |

## CHKHEMO3
<a id="chkhemo3"></a>

**Times Checked for Glycosylated Hemoglobin**

- Module: 2.5 Diabetes
- Type: Num
- Column (fixed-width file): 298-299
- PDF page: 52
- Description: A test for “A one C” measures the average level of blood sugar over the past three months. About how many times in the past 12 months has a doctor, nurse, or other health professional checked you for “A one C”?
- Notes: _ _ Number of times, 76 = 76 or more Section 06.12, DIABETE3, is coded 2, 3, 4, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 76 | Number of times [76=76 or more] | 25,250 | 85.83 | 84.29 |
| 88 | None | 1,549 | 5.27 | 6.47 |
| 98 | Never heard of ‘‘A one C’’ test | 653 | 2.22 | 2.44 |
| 77 | Don’t know/Not sure | 1,881 | 6.39 | 6.60 |
| 99 | Refused | 84 | 0.29 | 0.20 |
| BLANK | Not asked or Missing | 412,039 |  |  |

## FEETCHK
<a id="feetchk"></a>

**Times Feet Check for Sores/irritations**

- Module: 2.6 Diabetes
- Type: Num
- Column (fixed-width file): 300-301
- PDF page: 53
- Description: About how many times in the past 12 months has a health professional checked your feet for any sores or irritations?
- Notes: _ _ Number of times, 76=76 or more Section 06.12, DIABETE3, is coded 2, 3, 4, 7, 9, or Missing; or Module 2.03, FEETCHK2, is coded 555

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 76 | Number of times [76=76 or more] | 21,860 | 75.02 | 74.02 |
| 88 | None | 6,362 | 21.83 | 22.96 |
| 77 | Don’t know/Not sure | 839 | 2.88 | 2.75 |
| 99 | Refused | 78 | 0.27 | 0.27 |
| BLANK | Not asked or Missing | 412,317 |  |  |

## EYEEXAM
<a id="eyeexam"></a>

**Last Eye Exam Where Pupils Were Dilated**

- Module: 2.7 Diabetes
- Type: Num
- Column (fixed-width file): 302
- PDF page: 53
- Description: When was the last time you had an eye exam in which the pupils were dilated? This would have made you temporarily sensitive to bright light.
- Notes: Section 06.12, DIABETE3, is coded 2, 3, 4, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past month (anytime less than 1 month ago) | 6,248 | 21.24 | 19.81 |
| 2 | Within the past year (1 month but less than 12 months ago) | 14,648 | 49.79 | 48.06 |
| 3 | Within the past 2 years (1 year but less than 2 years ago) | 3,730 | 12.68 | 13.69 |
| 4 | 2 or more years ago | 3,438 | 11.69 | 12.98 |
| 7 | Don’t know/Not sure | 416 | 1.41 | 1.31 |
| 8 | Never | 905 | 3.08 | 4.06 |
| 9 | Refused | 32 | 0.11 | 0.08 |
| BLANK | Not asked or Missing | 412,039 |  |  |

## DIABEYE
<a id="diabeye"></a>

**Ever Told Diabetes Has Affected Eyes**

- Module: 2.8 Diabetes
- Type: Num
- Column (fixed-width file): 303
- PDF page: 54
- Description: Has a doctor ever told you that diabetes has affected your eyes or that you had retinopathy?
- Notes: Section 06.12, DIABETE3, is coded 2, 3, 4, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 5,330 | 18.12 | 18.68 |
| 2 | No | 23,694 | 80.55 | 80.02 |
| 7 | Don’t know/Not sure | 373 | 1.27 | 1.25 |
| 9 | Refused | 19 | 0.06 | 0.05 |
| BLANK | Not asked or Missing | 412,040 |  |  |

## DIABEDU
<a id="diabedu"></a>

**Ever Taken Class in Managing Diabetes**

- Module: 2.9 Diabetes
- Type: Num
- Column (fixed-width file): 304
- PDF page: 54
- Description: Have you ever taken a course or class in how to manage your diabetes yourself?
- Notes: Section 06.12, DIABETE3, is coded 2, 3, 4, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 16,362 | 55.62 | 53.98 |
| 2 | No | 12,926 | 43.94 | 45.65 |
| 7 | Don’t know/Not sure | 106 | 0.36 | 0.32 |
| 9 | Refused | 22 | 0.07 | 0.05 |
| BLANK | Not asked or Missing | 412,040 |  |  |

## PAINACT2
<a id="painact2"></a>

**How many days hard to do usual activities in past 30 days**

- Module: 3.1 Healthy Days (Symptoms)
- Type: Num
- Column (fixed-width file): 305-306
- PDF page: 54
- Description: During the past 30 days, for about how many days did pain make it hard for you to do your usual activities, such as self-care, work, or recreation?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| BLANK | Not asked or Missing | 441,456 |  |  |

## QLMENTL2
<a id="qlmentl2"></a>

**How many days depressed in past 30 days**

- Module: 3.2 Healthy Days (Symptoms)
- Type: Num
- Column (fixed-width file): 307-308
- PDF page: 55
- Description: During the past 30 days, for about how may days have you felt sad, blue, or depressed?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| BLANK | Not asked or Missing | 441,456 |  |  |

## QLSTRES2
<a id="qlstres2"></a>

**How many days felt anxious in past 30 days**

- Module: 3.3 Healthy Days (Symptoms)
- Type: Num
- Column (fixed-width file): 309-310
- PDF page: 55
- Description: During the past 30 days, for about how many days have you felt worried, tense, or anxious?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| BLANK | Not asked or Missing | 441,456 |  |  |

## QLHLTH2
<a id="qlhlth2"></a>

**How many days full of energy in past 30 days**

- Module: 3.4 Healthy Days (Symptoms)
- Type: Num
- Column (fixed-width file): 311-312
- PDF page: 55
- Description: During the past 30 days, for about how many days have you felt very healthy and full of energy?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| BLANK | Not asked or Missing | 441,456 |  |  |

## CAREGIV1
<a id="caregiv1"></a>

**Provided regular care for family or friend**

- Module: 4.1 Caregiver
- Type: Num
- Column (fixed-width file): 313
- PDF page: 55
- Prologue: People may provide regular care or assistance to a friend or family member who has a health problem or disability.
- Description: During the past 30 days, did you provide regular care or assistance to a friend or family member who has a health problem or disability?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 24,034 | 22.05 | 21.77 |
| 2 | No----Go to Module 4.09 CRGVEXPT | 84,412 | 77.45 | 77.79 |
| 7 | Don’t know/Not Sure----Go to Module 4.09 CRGVEXPT | 217 | 0.20 | 0.19 |
| 8 | Caregiving recipient died in past 30 days----Go to next module | 222 | 0.20 | 0.14 |
| 9 | Refused----Go to Module 4.09 CRGVEXPT | 110 | 0.10 | 0.11 |
| BLANK | Not asked or Missing | 332,461 |  |  |

## CRGVREL1
<a id="crgvrel1"></a>

**Relationship Of Person To Whom You Are Giving Care?**

- Module: 4.2 Caregiver
- Type: Num
- Column (fixed-width file): 314-315
- PDF page: 56
- Description: What is his/her relationship to you? For example is he/she your (mother/daughter or father/son)?
- Notes: Module 04.01, CARGIV1, is coded 2, 8, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Mother | 5,342 | 22.24 | 22.53 |
| 2 | Father | 1,956 | 8.14 | 9.80 |
| 3 | Mother-in-law | 967 | 4.03 | 4.02 |
| 4 | Father-in-law | 365 | 1.52 | 1.56 |
| 5 | Child | 2,078 | 8.65 | 9.06 |
| 6 | Husband | 2,475 | 10.30 | 7.24 |
| 7 | Wife | 1,709 | 7.11 | 6.23 |
| 8 | Same-sex partner | 35 | 0.15 | 0.19 |
| 9 | Brother or brother-in-law | 833 | 3.47 | 3.23 |
| 10 | Sister or sister-in-law | 1,156 | 4.81 | 4.15 |
| 11 | Grandmother | 858 | 3.57 | 6.30 |
| 12 | Grandfather | 290 | 1.21 | 2.23 |
| 13 | Grandchild | 214 | 0.89 | 0.65 |
| 14 | Other relative | 1,735 | 7.22 | 7.63 |
| 15 | Non-relative/Family friend | 3,849 | 16.02 | 14.40 |
| 77 | Don’t know/Not Sure | 43 | 0.18 | 0.14 |
| 99 | Refused | 115 | 0.48 | 0.63 |
| BLANK | Not asked or Missing | 417,436 |  |  |

## CRGVLNG1
<a id="crgvlng1"></a>

**How Long Provided Care For Person.**

- Module: 4.3 Caregiver
- Type: Num
- Column (fixed-width file): 316
- PDF page: 56
- Description: For how long have you provided care for that person? Would you say…
- Notes: Module 04.01, CARGIV1, is coded 2, 8, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Less than 30 days | 4,379 | 18.25 | 18.63 |
| 2 | 1 month to less than 6 months | 2,977 | 12.41 | 12.66 |
| 3 | 6 months to less than 2 years | 4,353 | 18.14 | 18.33 |
| 4 | 2 years to less than 5 years | 5,000 | 20.84 | 20.05 |
| 5 | More than 5 years | 6,933 | 28.89 | 28.96 |
| 7 | Don’t know/Not sure | 293 | 1.22 | 1.20 |
| 9 | Refused | 60 | 0.25 | 0.17 |
| BLANK | Not asked or Missing | 417,461 |  |  |

## CRGVHRS1
<a id="crgvhrs1"></a>

**How Many Hours Do You Provide Care For Person?**

- Module: 4.4 Caregiver
- Type: Num
- Column (fixed-width file): 317
- PDF page: 57
- Description: In an average week, how many hours do you provide care or assistance? Would you say…
- Notes: Module 04.01, CARGIV1, is coded 2, 8, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Up to 8 hours per week | 13,103 | 54.68 | 54.71 |
| 2 | 9 to 19 hours per week | 2,927 | 12.21 | 12.74 |
| 3 | 20 to 39 hours per week | 2,285 | 9.54 | 9.85 |
| 4 | 40 hours or more | 4,243 | 17.71 | 17.74 |
| 7 | Don’t know/Not sure | 1,203 | 5.02 | 4.28 |
| 9 | Refused | 202 | 0.84 | 0.68 |
| BLANK | Not asked or Missing | 417,493 |  |  |

## CRGVPRB1
<a id="crgvprb1"></a>

**What Is The Major Health Problem, Illness, Disability For Care For Person?**

- Module: 4.5 Caregiver
- Type: Num
- Column (fixed-width file): 318-319
- PDF page: 57
- Description: What is the main health problem, long-term illness, or disability that the person you care for has?
- Notes: Module 04.01, CARGIV1, is coded 2, 8, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Arthritis/Rheumatism | 1,473 | 6.15 | 5.95 |
| 2 | Asthma | 121 | 0.51 | 0.68 |
| 3 | Cancer | 1,910 | 7.98 | 8.66 |
| 4 | Chronic respiratory conditions such as Emphysema or COPD | 959 | 4.01 | 3.61 |
| 5 | Dementia and other Cognitive Impairment Disorders | 2,331 | 9.74 | 8.44 |
| 6 | Developmental Disabilities such as Autism, Down's Syndrome, and Spina Bifida | 796 | 3.33 | 3.71 |
| 7 | Diabetes | 1,328 | 5.55 | 5.94 |
| 8 | Heart Disease, Hypertension | 1,679 | 7.02 | 6.17 |
| 9 | Human Immunodeficiency Virus Infection (HIV) | 37 | 0.15 | 0.20 |
| 10 | Mental Illnesses, such as Anxiety, Depression, or Schizophrenia | 915 | 3.82 | 3.81 |
| 11 | Other organ failure or diseases such as kidney or liver problems | 571 | 2.39 | 2.37 |
| 12 | Substance Abuse or Addiction Disorders | 73 | 0.31 | 0.44 |
| 13 | Other | 10,620 | 44.38 | 44.90 |
| 77 | Don’t know/Not Sure | 549 | 2.29 | 2.58 |
| 99 | Refused | 570 | 2.38 | 2.54 |
| BLANK | Not asked or Missing | 417,524 |  |  |

## CRGVPERS
<a id="crgvpers"></a>

**Managed personal care**

- Module: 4.6 Caregiver
- Type: Num
- Column (fixed-width file): 320
- PDF page: 58
- Prologue: In the past 30 days, did you provide care for this person by…
- Description: …Managing personal care such as giving medications, feeding, dressing, or bathing?
- Notes: Module 04.01, CARGIV1, is coded 2, 8, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 12,099 | 50.62 | 52.67 |
| 2 | No | 11,657 | 48.77 | 46.83 |
| 7 | Don’t know/Not Sure | 57 | 0.24 | 0.17 |
| 9 | Refused | 89 | 0.37 | 0.33 |
| BLANK | Not asked or Missing | 417,554 |  |  |

## CRGVHOUS
<a id="crgvhous"></a>

**Managed household tasks**

- Module: 4.7 Caregiver
- Type: Num
- Column (fixed-width file): 321
- PDF page: 58
- Prologue: In the past 30 days, did you provide care for this person by…
- Description: …Managing household tasks such as cleaning, managing money, or preparing meals?
- Notes: Module 04.01, CARGIV1, is coded 2, 8, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 18,523 | 77.55 | 79.50 |
| 2 | No | 5,218 | 21.85 | 20.05 |
| 7 | Don’t know/Not Sure | 69 | 0.29 | 0.18 |
| 9 | Refused | 75 | 0.31 | 0.27 |
| BLANK | Not asked or Missing | 417,571 |  |  |

## CRGVMST2
<a id="crgvmst2"></a>

**Which support do you MOST need that you are not getting?**

- Module: 4.8 Caregiver
- Type: Num
- Column (fixed-width file): 322
- PDF page: 59
- Description: Of the following support services, which one do you MOST need, that you are not currently getting?
- Notes: Module 04.01, CARGIV1, is coded 2, 8, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Classes about giving care, such as giving medications | 319 | 1.34 | 1.38 |
| 2 | Help in getting access to services | 1,985 | 8.33 | 8.58 |
| 3 | Support groups | 639 | 2.68 | 2.65 |
| 4 | Individual counseling to help cope with giving care | 461 | 1.94 | 1.94 |
| 5 | Respite care | 643 | 2.70 | 2.43 |
| 6 | You don’t need any of these support services | 19,047 | 79.96 | 80.02 |
| 7 | Don’t know/Not Sure | 575 | 2.41 | 2.46 |
| 9 | Refused | 153 | 0.64 | 0.55 |
| BLANK | Not asked or Missing | 417,634 |  |  |

## CRGVEXPT
<a id="crgvexpt"></a>

**Do you expect to have a relative you will need to provide care for?**

- Module: 4.9 Caregiver
- Type: Num
- Column (fixed-width file): 323
- PDF page: 59
- Description: In the next 2 years, do you expect to provide care or assistance to a friend or family member who has a health problem or disability?
- Notes: Module 04.01, CARGIV1, is coded 8

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 12,998 | 15.35 | 15.84 |
| 2 | No | 65,424 | 77.25 | 77.70 |
| 7 | Don’t know/Not Sure | 6,076 | 7.17 | 6.25 |
| 9 | Refused | 189 | 0.22 | 0.21 |
| BLANK | Not asked or Missing | 356,769 |  |  |

## VIDFCLT2
<a id="vidfclt2"></a>

**Difficulty recognizing friend across street**

- Module: 5.1 Visual Impairment and Access to Eye Care
- Type: Num
- Column (fixed-width file): 324
- PDF page: 60
- Description: How much difficulty, if any, do you have in recognizing a friend across the street? Would you say—
- Notes: Section 07.02, AGE, is less than 40

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No difficulty | 2,498 | 78.09 | 79.20 |
| 2 | A little difficulty | 415 | 12.97 | 12.42 |
| 3 | Moderate difficulty | 176 | 5.50 | 5.35 |
| 4 | Extreme difficulty | 56 | 1.75 | 1.48 |
| 5 | Unable to do because of eyesight | 32 | 1.00 | 0.76 |
| 6 | Unable to do for other reasons | 10 | 0.31 | 0.33 |
| 7 | Don’t know/Not sure | 7 | 0.22 | 0.23 |
| 8 | Not applicable (Blind)----Go to Next Module | 5 | 0.16 | 0.22 |
| BLANK | Not asked or Missing | 438,257 |  |  |

## VIREDIF3
<a id="viredif3"></a>

**Difficulty reading typed text**

- Module: 5.2 Visual Impairment and Access to Eye Care
- Type: Num
- Column (fixed-width file): 325
- PDF page: 60
- Description: How much difficulty, if any, do you have reading print in newspapers, magazines, recipes, menus, or numbers on the telephone? Would you say—
- Notes: Section 07.02, AGE, is less than 40; or Module 05.01, VIDFCLT2, is coded as 8;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No difficulty | 1,888 | 59.22 | 59.71 |
| 2 | A little difficulty | 648 | 20.33 | 19.70 |
| 3 | Moderate difficulty | 415 | 13.02 | 13.11 |
| 4 | Extreme difficulty | 164 | 5.14 | 5.50 |
| 5 | Unable to do because of eyesight | 45 | 1.41 | 1.25 |
| 6 | Unable to do for other reasons | 14 | 0.44 | 0.37 |
| 7 | Don’t know/Not sure | 14 | 0.44 | 0.35 |
| BLANK | Not asked or Missing | 438,268 |  |  |

## VIPRFVS2
<a id="viprfvs2"></a>

**Last time visited eye care provider**

- Module: 5.3 Visual Impairment and Access to Eye Care
- Type: Num
- Column (fixed-width file): 326
- PDF page: 61
- Description: When was the last time you had your eyes examined by any doctor or eye care provider?
- Notes: Section 07.02, AGE, is less than 40; or Module 05.01, VIDFCLT2, is coded as 8; or Module 05.02, VIREDIF3, is coded as 8;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past month (anytime less than 1 month ago)----Go to Module 05.05 VIEYEXM2 | 504 | 15.81 | 13.30 |
| 2 | Within the past year (1month but less than 12 months ago)----Go to Module 05.05 VIEYEXM2 | 1,614 | 50.63 | 47.48 |
| 3 | Within the past 2 years (1years but less than 2 years ago) | 480 | 15.06 | 16.73 |
| 4 | 2 or more years ago | 522 | 16.37 | 18.74 |
| 5 | Never | 40 | 1.25 | 2.53 |
| 7 | Don’t know/Not sure | 26 | 0.82 | 1.13 |
| 9 | Refused | 2 | 0.06 | 0.08 |
| BLANK | Not asked or Missing | 438,268 |  |  |

## VINOCRE2
<a id="vinocre2"></a>

**Reason did not use eye doc past 12 mos**

- Module: 5.4 Visual Impairment and Access to Eye Care
- Type: Num
- Column (fixed-width file): 327-328
- PDF page: 61
- Description: What is the main reason you have not visited an eye care professional in the past 12 months?
- Notes: Section 07.02, AGE, is less than 40; or Module 05.01, VIDFCLT2, is coded as 8; or Module 05.02, VIREDIF3, is coded as 8; or Module 05.03, VIPRFVS2, is coded 1, 2, or 8;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Cost/insurance | 237 | 22.19 | 23.27 |
| 2 | Do not have/know an eye doctor | 14 | 1.31 | 1.56 |
| 3 | Cannot get to the office/clinic (too far away,no transportation) | 17 | 1.59 | 0.92 |
| 4 | Could not get an appointment | 10 | 0.94 | 1.18 |
| 5 | No reason to go (no problem) | 427 | 39.98 | 41.85 |
| 6 | Have not thought of it | 80 | 7.49 | 8.04 |
| 7 | Other | 259 | 24.25 | 20.76 |
| 8 | Not Applicable (Blind)----Go to Next Module | 2 | 0.19 | 0.70 |
| 77 | Don’t know/Not Sure | 18 | 1.69 | 1.47 |
| 99 | Refused | 4 | 0.37 | 0.26 |
| BLANK | Not asked or Missing | 440,388 |  |  |

## VIEYEXM2
<a id="vieyexm2"></a>

**When last eyexam**

- Module: 5.5 Visual Impairment and Access to Eye Care
- Type: Num
- Column (fixed-width file): 329
- PDF page: 62
- Description: When was the last time you had an eye exam in which the pupils were dilated? This would have made you temporarily sensitive to bright light.
- Notes: Section 07.02, AGE, is less than 40; or Module 2.07, EYEEXAM, is coded 1, 2, 3, 4, 7, 8 or 9; or Module 05.01, VIDFCLT2, is coded as 8; or Module 05.02, VIREDIF3, is coded as 8; or Module 05.03, VIPRFVS2, is coded as 8;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past month (anytime less than 1 month ago) | 258 | 10.20 | 8.38 |
| 2 | Within the past year (1 month but less than 12 months ago) | 1,091 | 43.14 | 37.47 |
| 3 | Within the past 2 years (1 year but less than 2 years) | 372 | 14.71 | 14.54 |
| 4 | 2 or more years ago | 549 | 21.71 | 24.15 |
| 5 | Never | 190 | 7.51 | 12.18 |
| 7 | Don’t know/Not Sure | 66 | 2.61 | 3.15 |
| 8 | Not applicable (Blind)----Go to Next Module | 1 | 0.04 | 0.04 |
| 9 | Refused | 2 | 0.08 | 0.09 |
| BLANK | Not asked or Missing | 438,927 |  |  |

## VIINSUR2
<a id="viinsur2"></a>

**Eye care health insurance**

- Module: 5.6 Visual Impairment and Access to Eye Care
- Type: Num
- Column (fixed-width file): 330
- PDF page: 62
- Description: Do you have any kind of health insurance coverage for eye care?
- Notes: Section 07.02, AGE, is less than 40; or Module 05.01, VIDFCLT2, is coded as 8; or Module 05.02, VIREDIF3, is coded as 8; or Module 05.03, VIPRFVS2, is coded as 8; or Module 05.04, VINOCRE2, is coded as 8; or Module 05.05, VIEYEXM2, is coded as 8;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 1,756 | 55.20 | 55.52 |
| 2 | No | 1,332 | 41.87 | 41.13 |
| 7 | Don’t know/Not Sure | 90 | 2.83 | 3.26 |
| 8 | Not applicable (Blind)----Go to Next Module | 1 | 0.03 | 0.04 |
| 9 | Refused | 2 | 0.06 | 0.05 |
| BLANK | Not asked or Missing | 438,275 |  |  |

## VICTRCT4
<a id="victrct4"></a>

**Hlth care pro said now have cataracts**

- Module: 5.7 Visual Impairment and Access to Eye Care
- Type: Num
- Column (fixed-width file): 331
- PDF page: 63
- Description: Have you been told by an eye doctor or other health care professional that you NOW have cataracts?
- Notes: Section 07.02, AGE, is less than 40; or Module 05.01, VIDFCLT2, is coded as 8; or Module 05.02, VIREDIF3, is coded as 8; or Module 05.03, VIPRFVS2, is coded as 8; or Module 05.04, VINOCRE2, is coded as 8; or Module 05.05, VIEYEXM2, is coded as 8; or Module 05.06, VINSUR2, is coded as 8

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 665 | 20.93 | 16.58 |
| 2 | No, I had them removed | 562 | 17.68 | 11.56 |
| 3 | No | 1,939 | 61.01 | 71.30 |
| 7 | Don’t know/Not Sure | 12 | 0.38 | 0.57 |
| BLANK | Not asked or Missing | 438,278 |  |  |

## VIGLUMA2
<a id="vigluma2"></a>

**Hlth care pro EVER said have glaucoma**

- Module: 5.8 Visual Impairment and Access to Eye Care
- Type: Num
- Column (fixed-width file): 332
- PDF page: 63
- Description: Have you EVER been told by an eye doctor or other health care professional that you had glaucoma?
- Notes: Section 07.02, AGE, is less than 40; or Module 05.01, VIDFCLT2, is coded as 8; or Module 05.02, VIREDIF3, is coded as 8; or Module 05.03, VIPRFVS2, is coded as 8; or Module 05.04, VINOCRE2, is coded as 8; or Module 05.05, VIEYEXM2, is coded as 8; or Module 05.06, VINSUR2, is coded as 8; or Module 05.07, VICTRCT4, is coded as 8

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 204 | 6.42 | 5.01 |
| 2 | No | 2,962 | 93.20 | 94.65 |
| 7 | Don’t know/Not Sure | 12 | 0.38 | 0.34 |
| BLANK | Not asked or Missing | 438,278 |  |  |

## VIMACDG2
<a id="vimacdg2"></a>

**Hlth care pro EVER said have macular degeneration**

- Module: 5.9 Visual Impairment and Access to Eye Care
- Type: Num
- Column (fixed-width file): 333
- PDF page: 64
- Description: Have you EVER been told by an eye doctor or other health care professional that you had age-related macular degeneration?
- Notes: Section 07.02, AGE, is less than 40; or Module 05.01, VIDFCLT2, is coded as 8; or Module 05.02, VIREDIF3, is coded as 8; or Module 05.03, VIPRFVS2, is coded as 8; or Module 05.04, VINOCRE2, is coded as 8; or Module 05.05, VIEYEXM2, is coded as 8; or Module 05.06, VINSUR2, is coded as 8; or Module 05.07, VICTRCT4, is coded as 8; or Module 05.08,

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 185 | 5.83 | 4.43 |
| 2 | No | 2,952 | 92.98 | 94.41 |
| 7 | Don’t know/Not Sure | 38 | 1.20 | 1.16 |
| BLANK | Not asked or Missing | 438,281 |  |  |

## CIMEMLOS
<a id="cimemlos"></a>

**Have you experienced confusion or memory loss that is happening more often or is getting worse?**

- Module: 6.1 Cognitive Decline
- Type: Num
- Column (fixed-width file): 334
- PDF page: 64
- Description: During the past 12 months, have you experienced confusion or memory loss that is happening more often or is getting worse?
- Notes: Section 07.02, AGE, is less than 45

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 12,404 | 10.63 | 11.14 |
| 2 | No----Go to next module | 103,278 | 88.48 | 88.15 |
| 7 | Don’t know/Not sure | 857 | 0.73 | 0.56 |
| 9 | Refused----Go to next module | 190 | 0.16 | 0.15 |
| BLANK | Not asked or Missing | 324,727 |  |  |

## CDHOUSE
<a id="cdhouse"></a>

**Given up day-to-day chores due to confusion or memory loss**

- Module: 6.2 Cognitive Decline
- Type: Num
- Column (fixed-width file): 335
- PDF page: 65
- Description: During the past 12 months, as a result of confusion or memory loss, how often have you given up day-to-day household activities or chores you used to do, such as cooking, cleaning, taking medications, driving, or paying bills?
- Notes: Section 07.02, AGE, is less than 45; or Module 06.01, CIMEMLOS, is coded 2 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Always | 929 | 7.01 | 7.56 |
| 2 | Usually | 835 | 6.30 | 6.71 |
| 3 | Sometimes | 3,192 | 24.08 | 26.12 |
| 4 | Rarely | 1,805 | 13.62 | 12.92 |
| 5 | Never | 6,194 | 46.73 | 44.54 |
| 7 | Don’t know/Not sure | 255 | 1.92 | 1.88 |
| 9 | Refused | 46 | 0.35 | 0.26 |
| BLANK | Not asked or Missing | 428,200 |  |  |

## CDASSIST
<a id="cdassist"></a>

**Need assistance with day-to_day activities due to confusion or memory loss**

- Module: 6.3 Cognitive Decline
- Type: Num
- Column (fixed-width file): 336
- PDF page: 65
- Description: As a result of confusion or memory loss, how often do you need assistance with these day-to-day activities?
- Notes: Section 07.02, AGE, is less than 45; or Module 06.01, CIMEMLOS, is coded 2 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Always | 821 | 6.20 | 6.70 |
| 2 | Usually | 672 | 5.08 | 5.64 |
| 3 | Sometimes | 2,836 | 21.42 | 23.18 |
| 4 | Rarely----Go to Module 6.05 CDDISCUS | 1,979 | 14.95 | 14.57 |
| 5 | Never----Go to Module 6.05 CDDISCUS | 6,764 | 51.08 | 48.74 |
| 7 | Don’t know/Not sure----Go to Module 6.05 CDDISCUS | 142 | 1.07 | 1.02 |
| 9 | Refused----Go to Module 6.05 CDDISCUS | 27 | 0.20 | 0.14 |
| BLANK | Not asked or Missing | 428,215 |  |  |

## CDHELP
<a id="cdhelp"></a>

**When you need help with day-to-day activities are you able to get it**

- Module: 6.4 Cognitive Decline
- Type: Num
- Column (fixed-width file): 337
- PDF page: 66
- Description: When you need help with these day-to-day activities, how often are you able to get the help that you need?
- Notes: Section 07.02, AGE, is less than 45; or Module 06.01, CIMEMLOS, is coded 2 or 9; or Module 06.03, CDASSIST, is coded 4, 5, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Always | 1,777 | 41.08 | 40.31 |
| 2 | Usually | 879 | 20.32 | 18.98 |
| 3 | Sometimes | 1,051 | 24.29 | 26.86 |
| 4 | Rarely | 318 | 7.35 | 6.33 |
| 5 | Never | 265 | 6.13 | 6.81 |
| 7 | Don’t know/Not sure | 34 | 0.79 | 0.68 |
| 9 | Refused | 2 | 0.05 | 0.03 |
| BLANK | Not asked or Missing | 437,130 |  |  |

## CDSOCIAL
<a id="cdsocial"></a>

**Does confusion or memory loss interfere with work or social activities**

- Module: 6.5 Cognitive Decline
- Type: Num
- Column (fixed-width file): 338
- PDF page: 66
- Description: During the past 12 months, how often has confusion or memory loss interfered with your ability to work, volunteer, or engage in social activities outside the home?
- Notes: Section 07.02, AGE, is less than 45; or Module 06.01, CIMEMLOS, is coded 2 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Always | 1,253 | 9.48 | 10.30 |
| 2 | Usually | 743 | 5.62 | 5.98 |
| 3 | Sometimes | 2,447 | 18.51 | 20.06 |
| 4 | Rarely | 1,924 | 14.56 | 14.24 |
| 5 | Never | 6,592 | 49.87 | 47.77 |
| 7 | Don’t know/Not sure | 224 | 1.69 | 1.47 |
| 9 | Refused | 35 | 0.26 | 0.17 |
| BLANK | Not asked or Missing | 428,238 |  |  |

## CDDISCUS
<a id="cddiscus"></a>

**Have you discussed your confusion or memory loss with a health care professional?**

- Module: 6.6 Cognitive Decline
- Type: Num
- Column (fixed-width file): 339
- PDF page: 67
- Description: Have you or anyone else discussed your confusion or memory loss with a health care professional?
- Notes: Section 07.02, AGE, is less than 45; or Module 06.01, CIMEMLOS, is coded 2 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 5,863 | 44.41 | 45.20 |
| 2 | No | 7,220 | 54.69 | 54.06 |
| 7 | Don’t know/Not Sure | 101 | 0.77 | 0.58 |
| 9 | Refused | 17 | 0.13 | 0.15 |
| BLANK | Not asked or Missing | 428,255 |  |  |

## WTCHSALT
<a id="wtchsalt"></a>

**Watching Sodium or Salt Intake**

- Module: 7.1 Sodium or Salt-Related Behavior
- Type: Num
- Column (fixed-width file): 340
- PDF page: 67
- Prologue: Now I would like to ask you some questions about sodium or salt intake. Most of the sodium or salt we eat comes from processed foods and foods prepared in restaurants. Salt also can be added in cooking or at the table.
- Description: Are you currently watching or reducing your sodium or salt intake?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 25,469 | 61.67 | 57.17 |
| 2 | No----Go to Module 07.03 DRADVISE | 15,604 | 37.78 | 42.21 |
| 7 | Don’t know/Not Sure----Go to Module 07.03 DRADVISE | 161 | 0.39 | 0.44 |
| 9 | Refused----Go to Module 07.03 DRADVISE | 65 | 0.16 | 0.18 |
| BLANK | Not asked or Missing | 400,157 |  |  |

## LONGWTCH
<a id="longwtch"></a>

**How Long Watching Salt/Sodium Intake**

- Module: 7.2 Sodium or Salt-Related Behavior
- Type: Num
- Column (fixed-width file): 341-343
- PDF page: 68
- Description: How many days, weeks, months, or years have you been watching or reducing your sodium or salt intake?
- Notes: Module 07.01, WTCHSALT, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 101 - 199 | Day(s) | 837 | 3.29 | 3.73 |
| 201 - 299 | Week(s) | 330 | 1.30 | 1.73 |
| 301 - 399 | Month(s) | 2,342 | 9.20 | 11.43 |
| 401 - 499 | Year(s) | 17,610 | 69.16 | 66.14 |
| 555 | All my life | 2,898 | 11.38 | 11.36 |
| 777 | Don’t know/Not Sure | 1,389 | 5.46 | 5.33 |
| 999 | Refused | 56 | 0.22 | 0.27 |
| BLANK | Not asked or Missing | 415,994 |  |  |

## DRADVISE
<a id="dradvise"></a>

**Doctor Advised Reduced Sodium/Salt Intake**

- Module: 7.3 Sodium or Salt-Related Behavior
- Type: Num
- Column (fixed-width file): 344
- PDF page: 68
- Description: Has a doctor or other health professional ever advised you to reduce sodium or salt intake?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 12,572 | 30.47 | 25.88 |
| 2 | No | 28,429 | 68.90 | 73.52 |
| 7 | Don’t know/Not Sure | 224 | 0.54 | 0.48 |
| 9 | Refused | 38 | 0.09 | 0.11 |
| BLANK | Not asked or Missing | 400,193 |  |  |

## ASTHMAGE
<a id="asthmage"></a>

**Age at Asthma Diagnosis**

- Module: 8.1 Adult Asthma History
- Type: Num
- Column (fixed-width file): 345-346
- PDF page: 68
- Prologue: Previously you said you were told by a doctor, nurse, or other health professional that you had asthma.
- Description: How old were you when you were first told by a doctor, nurse or other health professional that you had asthma?
- Notes: 96=96 and older Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 11 - 96 | Age 11 or older [96 = 96 and older] | 585 | 57.18 | 44.40 |
| 97 | Age 10 or younger | 344 | 33.63 | 47.75 |
| 98 | Don’t know/Not sure | 89 | 8.70 | 7.23 |
| 99 | Refused | 5 | 0.49 | 0.62 |
| BLANK | Not asked or Missing | 440,433 |  |  |

## ASATTACK
<a id="asattack"></a>

**Asthma During Past 12 Months**

- Module: 8.2 Adult Asthma History
- Type: Num
- Column (fixed-width file): 347
- PDF page: 69
- Description: During the past 12 months, have you had an episode of asthma or an asthma attack?
- Notes: Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing; or Section 06.05, ASTHNOW, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 313 | 48.30 | 50.96 |
| 2 | No----Go to Module 08.05 ASRCHKUP | 324 | 50.00 | 47.98 |
| 7 | Don’t know/Not sure----Go to Module 08.05 ASRCHKUP | 11 | 1.70 | 1.06 |
| BLANK | Not asked or Missing | 440,808 |  |  |

## ASERVIST
<a id="aservist"></a>

**Emergency Asthma Care During Past 12 Months**

- Module: 8.3 Adult Asthma History
- Type: Num
- Column (fixed-width file): 348-349
- PDF page: 69
- Description: During the past 12 months, how many times did you visit an emergency room or urgent care center because of your asthma?
- Notes: 87=87 or more Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing; or Section 06.05, ASTHNOW, is coded 2, 7, 9, or Missing; or Module 08.02, ASATTACK, is coded 2, 7, 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 87 | Number of visits [87 = 87 or more] | 104 | 33.23 | 36.65 |
| 88 | None | 205 | 65.50 | 59.76 |
| 98 | Don’t know/Not sure | 4 | 1.28 | 3.60 |
| BLANK | Not asked or Missing | 441,143 |  |  |

## ASDRVIST
<a id="asdrvist"></a>

**Urgent Asthma Treatment During Past 12 Months**

- Module: 8.4 Adult Asthma History
- Type: Num
- Column (fixed-width file): 350-351
- PDF page: 69
- Prologue: If one or more visits to Q3, fill in “Besides those emergency room or urgent care center visits,”]
- Description: During the past 12 months, how many times did you see a doctor, nurse or other health professional for urgent treatment of worsening asthma symptoms?
- Notes: 87=87 or more Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing; or Section 06.05, ASTHNOW, is coded 2, 7, 9, or Missing; or Module 08.02, ASATTACK, is coded 2, 7, 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 87 | Number of visits [87 = 87 or more] | 125 | 40.06 | 37.29 |
| 88 | None | 179 | 57.37 | 57.08 |
| 98 | Don’t know/Not sure | 8 | 2.56 | 5.63 |
| BLANK | Not asked or Missing | 441,144 |  |  |

## ASRCHKUP
<a id="asrchkup"></a>

**Routine Asthma Care During Past 12 Months**

- Module: 8.5 Adult Asthma History
- Type: Num
- Column (fixed-width file): 352-353
- PDF page: 70
- Description: During the past 12 months, how many times did you see a doctor, nurse, or other health professional for a routine checkup for your asthma?
- Notes: Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing; or Section 06.05, ASTHNOW, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 87 | Number of visits [87 = 87 or more] | 409 | 63.51 | 59.24 |
| 88 | None | 218 | 33.85 | 36.99 |
| 98 | Don’t know/Not sure | 15 | 2.33 | 3.75 |
| 99 | Refused | 2 | 0.31 | 0.02 |
| BLANK | Not asked or Missing | 440,812 |  |  |

## ASACTLIM
<a id="asactlim"></a>

**Activities Limited Because of Asthma During Past 12 Months**

- Module: 8.6 Adult Asthma History
- Type: Num
- Column (fixed-width file): 354-356
- PDF page: 70
- Description: During the past 12 months, how many days were you unable to work or carry out your usual activities because of your asthma?
- Notes: Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing; or Section 06.05, ASTHNOW, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 365 | Number of days | 147 | 22.83 | 23.10 |
| 777 | Don’t know/Not sure | 41 | 6.37 | 8.37 |
| 888 | None | 451 | 70.03 | 68.01 |
| 999 | Refused | 5 | 0.78 | 0.52 |
| BLANK | Not asked or Missing | 440,812 |  |  |

## ASYMPTOM
<a id="asymptom"></a>

**Asthma Symptoms During Past 30 Days**

- Module: 8.7 Adult Asthma History
- Type: Num
- Column (fixed-width file): 357
- PDF page: 71
- Description: Symptoms of asthma include cough, wheezing, shortness of breath, chest tightness and phlegm production when you don´t have a cold or respiratory infection. During the past 30 days, how often did you have any symptoms of asthma?
- Notes: Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing; or Section 06.05, ASTHNOW, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Less than once a week | 114 | 17.78 | 16.80 |
| 2 | Once or twice a week | 137 | 21.37 | 22.58 |
| 3 | More that 2 times a week, but not every day | 73 | 11.39 | 10.36 |
| 4 | Every day, but not all the time | 73 | 11.39 | 12.88 |
| 5 | Every day, all the time | 33 | 5.15 | 5.00 |
| 7 | Don’t know/Not sure | 25 | 3.90 | 4.14 |
| 8 | Not at any time----Go to Module 08.09 ASTHMED3 | 183 | 28.55 | 27.76 |
| 9 | Refused | 3 | 0.47 | 0.49 |
| BLANK | Not asked or Missing | 440,815 |  |  |

## ASNOSLEP
<a id="asnoslep"></a>

**Sleep Difficulty Because of Asthma During Past 30 Days**

- Module: 8.8 Adult Asthma History
- Type: Num
- Column (fixed-width file): 358
- PDF page: 71
- Description: During the past 30 days, how many days did symptoms of asthma make it difficult for you to stay asleep? Would you say—
- Notes: Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing; or Section 06.05, ASTHNOW, is coded 2, 7, 9, or Missing; or Module 08.07, ASYMPTOM, is coded 8

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | One or two | 70 | 15.32 | 13.59 |
| 2 | Three to four | 47 | 10.28 | 11.56 |
| 3 | Five | 23 | 5.03 | 6.58 |
| 4 | Six to ten | 29 | 6.35 | 6.00 |
| 5 | More than ten | 49 | 10.72 | 11.31 |
| 7 | Don’t know/Not sure | 16 | 3.50 | 4.55 |
| 8 | None | 223 | 48.80 | 46.41 |
| BLANK | Not asked or Missing | 440,999 |  |  |

## ASTHMED3
<a id="asthmed3"></a>

**Days used prescribed preventative asthma med in past 30 days**

- Module: 8.9 Adult Asthma History
- Type: Num
- Column (fixed-width file): 359
- PDF page: 72
- Description: During the past 30 days, how many days did you take a prescription asthma medication to PREVENT an asthma attack from occurring?
- Notes: Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing; or Section 06.05, ASTHNOW, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | 1 to 14 days | 128 | 20.03 | 20.29 |
| 2 | 15 to 24 days | 34 | 5.32 | 6.39 |
| 3 | 25 to 30 days | 243 | 38.03 | 30.26 |
| 7 | Don’t know/Not sure | 15 | 2.35 | 2.24 |
| 8 | Never | 214 | 33.49 | 40.48 |
| 9 | Refused | 5 | 0.78 | 0.34 |
| BLANK | Not asked or Missing | 440,817 |  |  |

## ASINHALR
<a id="asinhalr"></a>

**Times used asthma inhaler during an attack in past 30 days**

- Module: 8.10 Adult Asthma History
- Type: Num
- Column (fixed-width file): 360
- PDF page: 72
- Description: During the past 30 days, how often did you use a prescription asthma inhaler DURING AN ASTHMA ATTACK to stop it?
- Notes: Section 06.04, ASTHMA3, is coded 2, 7, 9, or Missing; or Section 06.05, ASTHNOW, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | 1 to 4 times (in the past 30 days) | 179 | 28.01 | 28.37 |
| 2 | 5 to 14 times (in the past 30 days) | 49 | 7.67 | 8.46 |
| 3 | 15 to 29 times (in the past 30 days) | 29 | 4.54 | 5.33 |
| 4 | 30 to 59 times (in the past 30 days) | 46 | 7.20 | 6.19 |
| 5 | 60 to 99 times (in the past 30 days) | 12 | 1.88 | 1.53 |
| 6 | 100 or more times (in the past 30 days) | 5 | 0.78 | 0.44 |
| 7 | Don’t know/Not sure | 10 | 1.56 | 1.20 |
| 8 | Never (include no attack in past 30 days) | 305 | 47.73 | 48.17 |
| 9 | Refused | 4 | 0.63 | 0.31 |
| BLANK | Not asked or Missing | 440,817 |  |  |

## HAREHAB1
<a id="harehab1"></a>

**Outpatient rehab after heart attack hosp stay**

- Module: 9.1 Cardiovascular Health
- Type: Num
- Column (fixed-width file): 361
- PDF page: 73
- Description: Following your heart attack, did you go to any kind of outpatient rehabilitation? This is sometimes called “rehab.”
- Notes: Section 06.01, CVDINFR4, is coded 2, 7, 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 403 | 39.86 | 31.71 |
| 2 | No | 592 | 58.56 | 66.50 |
| 7 | Don’t know/Not Sure | 10 | 0.99 | 0.80 |
| 9 | Refused | 6 | 0.59 | 0.99 |
| BLANK | Not asked or Missing | 440,445 |  |  |

## STREHAB1
<a id="strehab1"></a>

**Outpatient rehab after hosp stay for stroke**

- Module: 9.2 Cardiovascular Health
- Type: Num
- Column (fixed-width file): 362
- PDF page: 73
- Description: Following your stroke did you go to any kind of outpatient rehabilitation? This is sometimes called “rehab.”
- Notes: Section 06.03, CVDSTRK3, is coded 2, 7, 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 260 | 37.46 | 37.11 |
| 2 | No | 426 | 61.38 | 62.42 |
| 7 | Don’t know/Not Sure | 5 | 0.72 | 0.18 |
| 9 | Refused | 3 | 0.43 | 0.29 |
| BLANK | Not asked or Missing | 440,762 |  |  |

## CVDASPRN
<a id="cvdasprn"></a>

**Take Aspirin Daily or Every Other Day**

- Module: 9.3 Cardiovascular Health
- Type: Num
- Column (fixed-width file): 363
- PDF page: 73
- Description: Do you take aspirin daily or every other day?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes----Go to Module 09.05 RLIVPAIN | 5,620 | 29.90 | 23.27 |
| 2 | No | 13,150 | 69.95 | 76.53 |
| 7 | Don’t know/Not sure | 23 | 0.12 | 0.14 |
| 9 | Refused | 5 | 0.03 | 0.06 |
| BLANK | Not asked or Missing | 422,658 |  |  |

## ASPUNSAF
<a id="aspunsaf"></a>

**Health Makes Taking Aspirin Unsafe**

- Module: 9.4 Cardiovascular Health
- Type: Num
- Column (fixed-width file): 364
- PDF page: 74
- Description: Do you have a health problem or condition that makes taking aspirin unsafe for you? (If "Yes," ask "Is this a stomach condition?")
- Notes: Module 09.03, CVDASPRN, is coded 1

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes, not stomach related----Go to next module | 967 | 7.34 | 5.11 |
| 2 | Yes, stomach problems----Go to next module | 570 | 4.33 | 3.07 |
| 3 | No----Go to next module | 11,518 | 87.41 | 90.98 |
| 7 | Don’t know/Not sure----Go to next module | 110 | 0.83 | 0.72 |
| 9 | Refused----Go to next module | 12 | 0.09 | 0.13 |
| BLANK | Not asked or Missing | 428,279 |  |  |

## RLIVPAIN
<a id="rlivpain"></a>

**Take Aspirin to Relieve Pain**

- Module: 9.5 Cardiovascular Health
- Type: Num
- Column (fixed-width file): 365
- PDF page: 74
- Description: Do you take aspirin to relieve pain?
- Notes: Module 09.04, ASPUNSAF, is coded 1, 2, 3, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 1,163 | 20.70 | 24.80 |
| 2 | No | 4,429 | 78.82 | 74.39 |
| 7 | Don’t know/Not Sure | 24 | 0.43 | 0.80 |
| 9 | Refused | 3 | 0.05 | 0.01 |
| BLANK | Not asked or Missing | 435,837 |  |  |

## RDUCHART
<a id="rduchart"></a>

**Take Aspirin to Reduce Chance of Heart Attack**

- Module: 9.6 Cardiovascular Health
- Type: Num
- Column (fixed-width file): 366
- PDF page: 74
- Description: Do you take aspirin to reduce the chance of a heart attack?
- Notes: Module 09.04, ASPUNSAF, is coded 1, 2, 3, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 4,663 | 82.99 | 79.87 |
| 2 | No | 807 | 14.36 | 17.49 |
| 7 | Don’t know/Not Sure | 148 | 2.63 | 2.63 |
| 9 | Refused | 1 | 0.02 | 0.01 |
| BLANK | Not asked or Missing | 435,837 |  |  |

## RDUCSTRK
<a id="rducstrk"></a>

**Take Aspirin to Reduce Chance of Stroke**

- Module: 9.7 Cardiovascular Health
- Type: Num
- Column (fixed-width file): 367
- PDF page: 75
- Description: Do you take aspirin to reduce the chance of a stroke?
- Notes: Module 09.04, ASPUNSAF, is coded 1, 2, 3, 7 or 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 3,710 | 66.04 | 62.72 |
| 2 | No | 1,487 | 26.47 | 31.10 |
| 7 | Don’t know/Not Sure | 416 | 7.40 | 6.08 |
| 9 | Refused | 5 | 0.09 | 0.11 |
| BLANK | Not asked or Missing | 435,838 |  |  |

## ARTTODAY
<a id="arttoday"></a>

**What Can You Do Because of Arthritis or Joint Symptoms**

- Module: 10.1 Arthritis Management
- Type: Num
- Column (fixed-width file): 368
- PDF page: 75
- Prologue: Earlier you indicated that you had arthritis or joint symptoms.
- Description: Thinking about your arthritis or joint symptoms, which of the following best describes you TODAY?
- Notes: Section 06.09, HAVARTH3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | I can do everything I would like to do | 4,483 | 22.77 | 23.84 |
| 2 | I can do most things I would like to do | 8,382 | 42.58 | 41.67 |
| 3 | I can do some things I would like to do | 4,862 | 24.70 | 24.70 |
| 4 | I can hardly do anything I would like to do | 1,829 | 9.29 | 9.27 |
| 7 | Don´t know/Not Sure | 90 | 0.46 | 0.36 |
| 9 | Refused | 41 | 0.21 | 0.16 |
| BLANK | Not asked or Missing | 421,769 |  |  |

## ARTHWGT
<a id="arthwgt"></a>

**Dr. Suggest Lose Weight for Arthritis or Joint Symptoms**

- Module: 10.2 Arthritis Management
- Type: Num
- Column (fixed-width file): 369
- PDF page: 75
- Description: Has a doctor or other health professional EVER suggested losing weight to help your arthritis or joint symptoms?
- Notes: Section 06.09, HAVARTH3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 7,114 | 36.16 | 36.43 |
| 2 | No | 12,419 | 63.12 | 63.04 |
| 7 | Don´t know/Not Sure | 109 | 0.55 | 0.38 |
| 9 | Refused | 33 | 0.17 | 0.15 |
| BLANK | Not asked or Missing | 421,781 |  |  |

## ARTHEXER
<a id="arthexer"></a>

**Dr. Suggest Use of Physical Activity or Exercise for Arthritis or Joint Symptoms**

- Module: 10.3 Arthritis Management
- Type: Num
- Column (fixed-width file): 370
- PDF page: 76
- Description: Has a doctor or other health professional EVER suggested physical activity or exercise to help your arthritis or joint symptoms? (If the respondent is unclear about whether this means an increase or decrease in physical activity, this means increase.)
- Notes: Section 06.09, HAVARTH3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 11,248 | 57.18 | 57.10 |
| 2 | No | 8,179 | 41.58 | 41.71 |
| 7 | Don´t know/Not Sure | 206 | 1.05 | 1.04 |
| 9 | Refused | 37 | 0.19 | 0.15 |
| BLANK | Not asked or Missing | 421,786 |  |  |

## ARTHEDU
<a id="arthedu"></a>

**Ever Taken Class in Managing Arthritis or Joint Symptoms**

- Module: 10.4 Arthritis Management
- Type: Num
- Column (fixed-width file): 371
- PDF page: 76
- Description: Have you EVER taken an educational course or class to teach you how to manage problems related to your arthritis or joint symptoms?
- Notes: Section 06.09, HAVARTH3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 2,566 | 13.05 | 12.50 |
| 2 | No | 16,997 | 86.45 | 86.96 |
| 7 | Don´t know/Not Sure | 67 | 0.34 | 0.41 |
| 9 | Refused | 30 | 0.15 | 0.13 |
| BLANK | Not asked or Missing | 421,796 |  |  |

## TETANUS
<a id="tetanus"></a>

**Received Tetanus Shot Since 2005?**

- Module: 11.1 Tetanus Diphtheria (TDAP) (Adults)
- Type: Num
- Column (fixed-width file): 372
- PDF page: 77
- Description: Since 2005, have you had a tetanus shot? (If yes, ask: “Was this Tdap, the tetanus shot that also has pertussis or whooping cough vaccine?”)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes, received Tdap | 6,449 | 15.89 | 17.80 |
| 2 | Yes, received tetanus shot, but not Tdap | 2,944 | 7.25 | 6.87 |
| 3 | Yes, received tetanus shot but not sure what type | 9,896 | 24.38 | 25.60 |
| 4 | No, did not receive any tetanus since 2005 | 17,243 | 42.48 | 39.94 |
| 7 | Don’t know/Not Sure | 4,034 | 9.94 | 9.74 |
| 9 | Refused | 21 | 0.05 | 0.06 |
| BLANK | Not asked or Missing | 400,869 |  |  |

## HPVADVC2
<a id="hpvadvc2"></a>

**Have you ever had the HPV vaccination?**

- Module: 12.1 Adult Human Papillomavirus (HPV) - Vaccination
- Type: Num
- Column (fixed-width file): 373
- PDF page: 77
- Prologue: A vaccine to prevent the human papilloma virus or HPV infection is available and is called the cervical cancer or genital warts vaccine, HPV shot, [Fill: if female “GARDASIL or CERVARIX”, if male “GARDASIL”].
- Description: Have you ever had the HPV vaccination? (Human Papilloma Virus (Human Pap•uh•loh•muh Virus), Gardasil (Gar•duh• seel), Cervarix (Serv a rix))
- Notes: Section 07.02, AGE, is greater than 49

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 1,448 | 13.26 | 15.39 |
| 2 | No----Go to Next Module | 8,414 | 77.03 | 75.10 |
| 3 | Doctor refused when asked----Go to Next Module | 14 | 0.13 | 0.11 |
| 7 | Don’t know/Not Sure----Go to Next Module | 1,017 | 9.31 | 9.00 |
| 9 | Refused----Go to Next Module | 30 | 0.27 | 0.40 |
| BLANK | Not asked or Missing | 430,533 |  |  |

## HPVADSHT
<a id="hpvadsht"></a>

**How many HPV shots did you receive?**

- Module: 12.2 Adult Human Papillomavirus (HPV) - Vaccination
- Type: Num
- Column (fixed-width file): 374-375
- PDF page: 78
- Description: How many HPV shots did you receive?
- Notes: Section 07.02, AGE, is greater than 49; or Module 11.01, HPVADVC2, is coded 2, 3, 7, 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 2 | Number of shots | 435 | 30.04 | 32.36 |
| 3 | All shots | 789 | 54.49 | 52.25 |
| 77 | Don’t know/Not Sure | 221 | 15.26 | 15.16 |
| 99 | Refused | 3 | 0.21 | 0.24 |
| BLANK | Not asked or Missing | 440,008 |  |  |

## SHINGLE2
<a id="shingle2"></a>

**Have you ever had the shingles or zoster vaccine?**

- Module: 13.1 Shingles (Zostavax or ZOS)
- Type: Num
- Column (fixed-width file): 376
- PDF page: 78
- Prologue: The next question is about the Shingles vaccine.
- Description: Have you ever had the shingles or zoster vaccine?
- Notes: Section 07.02, AGE, is less than 50

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 7,870 | 28.05 | 23.18 |
| 2 | No | 19,719 | 70.28 | 74.94 |
| 7 | Don’t know/Not Sure | 455 | 1.62 | 1.81 |
| 9 | Refused | 15 | 0.05 | 0.08 |
| BLANK | Not asked or Missing | 413,397 |  |  |

## HADMAM
<a id="hadmam"></a>

**Have You Ever Had a Mammogram**

- Module: 14.1 Breast and Cervical Cancer Screening
- Type: Num
- Column (fixed-width file): 377
- PDF page: 78
- Description: A mammogram is an x-ray of each breast to look for breast cancer. Have you ever had a mammogram?
- Notes: Section 07.01, SEX, is coded 1

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 18,545 | 81.29 | 68.48 |
| 2 | No----Go to Module 14.03 HADPAP2 | 4,191 | 18.37 | 31.08 |
| 7 | Don’t know/Not sure----Go to Module 14.03 HADPAP2 | 38 | 0.17 | 0.15 |
| 9 | Refused----Go to Module 14.03 HADPAP2 | 39 | 0.17 | 0.28 |
| BLANK | Not asked or Missing | 418,643 |  |  |

## HOWLONG
<a id="howlong"></a>

**How Long since Last Mammogram**

- Module: 14.2 Breast and Cervical Cancer Screening
- Type: Num
- Column (fixed-width file): 378
- PDF page: 79
- Description: How long has it been since you had your last mammogram?
- Notes: Section 07.01, SEX, is coded 1; or Module 14.01, HADMAM, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past year (anytime less than 12 months ago) | 11,413 | 61.55 | 61.10 |
| 2 | Within the past 2 years (1 year but less than 2 years ago) | 3,194 | 17.23 | 17.81 |
| 3 | Within the past 3 years (2 years but less than 3 years ago) | 1,256 | 6.77 | 7.11 |
| 4 | Within the past 5 years (3 years but less than 5 years ago) | 955 | 5.15 | 4.95 |
| 5 | 5 or more years ago | 1,550 | 8.36 | 8.01 |
| 7 | Don’t know/Not sure | 160 | 0.86 | 0.93 |
| 9 | Refused | 14 | 0.08 | 0.09 |
| BLANK | Not asked or Missing | 422,914 |  |  |

## HADPAP2
<a id="hadpap2"></a>

**Ever Had a Pap Test**

- Module: 14.3 Breast and Cervical Cancer Screening
- Type: Num
- Column (fixed-width file): 379
- PDF page: 79
- Description: A Pap test is a test for cancer of the cervix. Have you ever had a Pap test?
- Notes: Section 07.01, SEX, is coded 1

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 21,271 | 93.29 | 90.10 |
| 2 | No----Go to Module 14.05 HPVTEST | 1,369 | 6.00 | 9.05 |
| 7 | Don’t know/Not sure----Go to Module 14.05 HPVTEST | 122 | 0.54 | 0.60 |
| 9 | Refused----Go to Module 14.05 HPVTEST | 40 | 0.18 | 0.25 |
| BLANK | Not asked or Missing | 418,654 |  |  |

## LASTPAP2
<a id="lastpap2"></a>

**How Long Since Last Pap Test**

- Module: 14.4 Breast and Cervical Cancer Screening
- Type: Num
- Column (fixed-width file): 380
- PDF page: 80
- Description: How long has it been since you had your last Pap test?
- Notes: Section 07.01, SEX, is coded 1; or Module 14.03, HADPAP2, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past year (anytime less than 12 months ago) | 8,592 | 40.40 | 47.94 |
| 2 | Within the past 2 years (1 year but less than 2 years ago) | 3,936 | 18.51 | 19.07 |
| 3 | Within the past 3 years (2 years but less than 3 years ago) | 2,126 | 10.00 | 9.02 |
| 4 | Within the past 5 years (3 years but less than 5 years ago) | 1,568 | 7.37 | 6.32 |
| 5 | 5 or more years ago | 4,543 | 21.36 | 15.49 |
| 7 | Don’t know/Not sure | 485 | 2.28 | 2.08 |
| 9 | Refused | 17 | 0.08 | 0.08 |
| BLANK | Not asked or Missing | 420,189 |  |  |

## HPVTEST
<a id="hpvtest"></a>

**Have you ever had an HPV test?**

- Module: 14.5 Breast and Cervical Cancer Screening
- Type: Num
- Column (fixed-width file): 381
- PDF page: 80
- Prologue: Now, I would like to ask you about the Human Papillomavirus (Pap•uh•loh•muh Virus) or HPV.
- Description: An HPV test is sometimes given with the Pap test for cervical cancer screening. Have you ever had an HPV test?
- Notes: Section 07.01, SEX, is coded 1

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 6,909 | 30.32 | 34.91 |
| 2 | No----Go to Module 14.07 HADHYST2 | 9,310 | 40.85 | 37.40 |
| 7 | Don’t know/Not Sure----Go to Module 14.07 HADHYST2 | 6,523 | 28.62 | 27.43 |
| 9 | Refused----Go to Module 14.07 HADHYST2 | 47 | 0.21 | 0.26 |
| BLANK | Not asked or Missing | 418,667 |  |  |

## HPLSTTST
<a id="hplsttst"></a>

**How long since your last HPV test?**

- Module: 14.6 Breast and Cervical Cancer Screening
- Type: Num
- Column (fixed-width file): 382
- PDF page: 81
- Description: How long has it been since you had your last HPV test?
- Notes: Section 07.01, SEX, is coded 1; or Module 10.01, HPVTEST, is coded 2, 7, 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past year (anytime less than 12 months ago) | 3,075 | 44.52 | 51.79 |
| 2 | Within the past 2 years (1 year but less than 2 years ago) | 1,203 | 17.42 | 17.23 |
| 3 | Within the past 3 years (2 years but less than 3 years ago) | 612 | 8.86 | 7.92 |
| 4 | Within the past 5 years (3 years but less than 5 years ago) | 481 | 6.96 | 5.90 |
| 5 | 5 or more years ago | 1,159 | 16.78 | 12.49 |
| 7 | Don’t know/Not Sure | 374 | 5.41 | 4.60 |
| 9 | Refused | 3 | 0.04 | 0.07 |
| BLANK | Not asked or Missing | 434,549 |  |  |

## HADHYST2
<a id="hadhyst2"></a>

**Had Hysterectomy**

- Module: 14.7 Breast and Cervical Cancer Screening
- Type: Num
- Column (fixed-width file): 383
- PDF page: 81
- Description: Have you had a hysterectomy? (A hysterectomy is an operation to remove the uterus (womb).)
- Notes: Section 07.01, SEX, is coded 1; or Section 07.21, PREGNANT, is coded 1

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 6,328 | 28.04 | 23.06 |
| 2 | No | 16,133 | 71.49 | 76.30 |
| 7 | Don’t know/Not sure | 52 | 0.23 | 0.32 |
| 9 | Refused | 54 | 0.24 | 0.32 |
| BLANK | Not asked or Missing | 418,889 |  |  |

## PROFEXAM
<a id="profexam"></a>

**Ever Had Breast Physical Exam by Doctor**

- Module: 15.1 Clinical Breast Exam for Breast Cancer Screening
- Type: Num
- Column (fixed-width file): 384
- PDF page: 82
- Description: A clinical breast exam is when a doctor, nurse, or other health professional feels the breast for lumps. Have you ever had a clinical breast exam?
- Notes: Section 07.01, SEX, is coded 1

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 4,935 | 87.42 | 85.97 |
| 2 | No----Go to next module | 690 | 12.22 | 13.50 |
| 7 | Don’t know/Not sure----Go to next module | 14 | 0.25 | 0.29 |
| 9 | Refused----Go to next module | 6 | 0.11 | 0.24 |
| BLANK | Not asked or Missing | 435,811 |  |  |

## LENGEXAM
<a id="lengexam"></a>

**How Long since Last Breast Physical Exam**

- Module: 15.2 Clinical Breast Exam for Breast Cancer Screening
- Type: Num
- Column (fixed-width file): 385
- PDF page: 82
- Description: How long has it been since your last breast exam?
- Notes: Section 07.01, SEX, is coded 1; or Module 15.01, PROFEXAM, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past year (anytime less than 12 months ago) | 3,029 | 61.40 | 64.18 |
| 2 | Within the past 2 years (1 year but less than 2 years ago) | 840 | 17.03 | 17.17 |
| 3 | Within the past 3 years (2 years but less than 3 years ago) | 338 | 6.85 | 6.06 |
| 4 | Within the past 5 years (3 years but less than 5 years ago) | 226 | 4.58 | 4.69 |
| 5 | 5 or more years ago | 447 | 9.06 | 6.95 |
| 7 | Don’t know/Not sure | 49 | 0.99 | 0.88 |
| 9 | Refused | 4 | 0.08 | 0.09 |
| BLANK | Not asked or Missing | 436,523 |  |  |

## BLDSTOOL
<a id="bldstool"></a>

**Ever Had Blood Stool Test Using Home Kit**

- Module: 16.1 Colorectal Cancer Screening
- Type: Num
- Column (fixed-width file): 386
- PDF page: 83
- Description: A blood stool test is a test that may use a special kit at home to determine whether the stool contains blood. Have you ever had this test using a home kit?
- Notes: Section 07.02, AGE, is less than 50

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 19,780 | 36.38 | 31.81 |
| 2 | No----Go to Module 16.03 HADSIGM3 | 34,100 | 62.71 | 67.16 |
| 7 | Don’t know/Not Sure----Go to Module 16.03 HADSIGM3 | 443 | 0.81 | 0.91 |
| 9 | Refused----Go to Module 16.03 HADSIGM3 | 52 | 0.10 | 0.13 |
| BLANK | Not asked or Missing | 387,081 |  |  |

## LSTBLDS3
<a id="lstblds3"></a>

**Time Since Last Blood Stool Test**

- Module: 16.2 Colorectal Cancer Screening
- Type: Num
- Column (fixed-width file): 387
- PDF page: 83
- Description: How long has it been since you had your last blood stool test using a home kit?
- Notes: Section 07.02, AGE, is less than 50; or Module 16.01, BLDSTOOL, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past year (anytime less than 12 months ago) | 5,324 | 26.92 | 29.77 |
| 2 | Within the past 2 years (1 year but less than 2 years ago) | 2,683 | 13.57 | 14.57 |
| 3 | Within the past 3 years (2 years but less than 3 years ago) | 1,932 | 9.77 | 9.81 |
| 4 | Within the past 5 years (3 years but less than 5 years ago) | 2,351 | 11.89 | 11.86 |
| 5 | 5 or more years ago | 6,899 | 34.88 | 30.87 |
| 7 | Don’t know/Not sure | 571 | 2.89 | 3.03 |
| 9 | Refused | 17 | 0.09 | 0.09 |
| BLANK | Not asked or Missing | 421,679 |  |  |

## HADSIGM3
<a id="hadsigm3"></a>

**Ever Had Sigmoidoscopy/Colonoscopy**

- Module: 16.3 Colorectal Cancer Screening
- Type: Num
- Column (fixed-width file): 388
- PDF page: 84
- Description: Sigmoidoscopy and colonoscopy are exams in which a tube is inserted in the rectum to view the colon for signs of cancer or other health problems. Have you ever had either of these exams?
- Notes: Section 07.02, AGE, is less than 50

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 39,382 | 72.47 | 69.61 |
| 2 | No----Go to next module | 14,660 | 26.98 | 29.82 |
| 7 | Don’t know/Not Sure----Go to next module | 237 | 0.44 | 0.40 |
| 9 | Refused----Go to next module | 64 | 0.12 | 0.17 |
| BLANK | Not asked or Missing | 387,113 |  |  |

## HADSGCO1
<a id="hadsgco1"></a>

**Was your last test a sigmoidoscopy or colonoscopy?**

- Module: 16.4 Colorectal Cancer Screening
- Type: Num
- Column (fixed-width file): 389
- PDF page: 84
- Description: For a SIGMOIDOSCOPY, a flexible tube is inserted into the rectum to look for problems. A COLONOSCOPY is similar, but uses a longer tube, and you are usually given medication through a needle in your arm to make you sleepy and told to have someone else drive you home after the test. Was your MOST RECENT exam a sigmoidoscopy or a colonoscopy?
- Notes: Section 07.02, AGE, is less than 50; or Module 16.03, HADSIGM3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Sigmoidoscopy | 1,529 | 3.88 | 3.47 |
| 2 | Colonoscopy | 37,016 | 94.04 | 94.13 |
| 7 | Don’t know/Not Sure | 791 | 2.01 | 2.35 |
| 9 | Refused | 25 | 0.06 | 0.06 |
| BLANK | Not asked or Missing | 402,095 |  |  |

## LASTSIG3
<a id="lastsig3"></a>

**Time Since Last Sigmoidoscopy/Colonoscopy**

- Module: 16.5 Colorectal Cancer Screening
- Type: Num
- Column (fixed-width file): 390
- PDF page: 85
- Description: How long has it been since you had your last sigmoidoscopy or colonoscopy?
- Notes: Section 07.02, AGE, is less than 50; or Module 16.03, HADSIGM3, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past year (anytime less than 12 months ago) | 8,465 | 21.51 | 23.99 |
| 2 | Within the past 2 years (1 year but less than 2 years ago) | 6,161 | 15.65 | 16.75 |
| 3 | Within the past 3 years (2 years but less than 3 years ago) | 5,780 | 14.69 | 14.65 |
| 4 | Within the past 5 years (3 years but less than 5 years ago) | 8,376 | 21.28 | 20.73 |
| 5 | Within the past 10 years (5 years but less than 10 years ago) | 7,394 | 18.79 | 16.73 |
| 6 | 10 or more years ago | 2,636 | 6.70 | 5.70 |
| 7 | Don’t know/Not sure | 514 | 1.31 | 1.39 |
| 9 | Refused | 32 | 0.08 | 0.07 |
| BLANK | Not asked or Missing | 402,098 |  |  |

## PCPSAAD2
<a id="pcpsaad2"></a>

**Has a health professional EVER talked with you about the advantages of the PSA test?**

- Module: 17.1 Prostate Cancer Screening
- Type: Num
- Column (fixed-width file): 391
- PDF page: 85
- Prologue: A Prostate-Specific Antigen test, also called a PSA test, is a blood test used to check men for prostate cancer.
- Description: Has a doctor, nurse, or other health professional EVER talked with you about the advantages of the PSA test?
- Notes: Section 07.02, AGE, is less than 40; or Section 07.01, SEX, is coded 2;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 3,884 | 58.61 | 55.52 |
| 2 | No | 2,459 | 37.11 | 39.51 |
| 7 | Don’t know/Not Sure | 253 | 3.82 | 4.18 |
| 9 | Refused | 31 | 0.47 | 0.79 |
| BLANK | Not asked or Missing | 434,829 |  |  |

## PCPSADI1
<a id="pcpsadi1"></a>

**Has a health professional EVER talked with you about the disadvantages of the PSA test?**

- Module: 17.2 Prostate Cancer Screening
- Type: Num
- Column (fixed-width file): 392
- PDF page: 86
- Description: Has a doctor, nurse, or other health professional EVER talked with you about the disadvantages of the PSA test?
- Notes: Section 07.02, AGE, is less than 40; or Section 07.01, SEX, is coded 2

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 1,820 | 27.49 | 25.24 |
| 2 | No | 4,487 | 67.78 | 69.55 |
| 7 | Don’t know/Not Sure | 286 | 4.32 | 4.49 |
| 9 | Refused | 27 | 0.41 | 0.72 |
| BLANK | Not asked or Missing | 434,836 |  |  |

## PCPSARE1
<a id="pcpsare1"></a>

**Has a doctor EVER recommended that you have a PSA test?**

- Module: 17.3 Prostate Cancer Screening
- Type: Num
- Column (fixed-width file): 393
- PDF page: 86
- Description: Has a doctor, nurse, or other health professional EVER recommended that you have a PSA test?
- Notes: Section 07.02, AGE, is less than 40; or Section 07.01, SEX, is coded 2;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 3,455 | 52.23 | 49.26 |
| 2 | No | 2,888 | 43.66 | 46.19 |
| 7 | Don’t know/Not Sure | 238 | 3.60 | 3.82 |
| 9 | Refused | 34 | 0.51 | 0.73 |
| BLANK | Not asked or Missing | 434,841 |  |  |

## PSATEST1
<a id="psatest1"></a>

**Ever Had PSA Test**

- Module: 17.4 Prostate Cancer Screening
- Type: Num
- Column (fixed-width file): 394
- PDF page: 86
- Description: Have you EVER HAD a PSA test?
- Notes: Section 07.02, AGE, is less than 40; or Section 07.01, SEX, is coded 2;

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 3,635 | 54.95 | 49.19 |
| 2 | No----Go to next module | 2,684 | 40.57 | 45.51 |
| 7 | Don’t know/Not Sure----Go to next module | 267 | 4.04 | 4.63 |
| 9 | Refused----Go to next module | 29 | 0.44 | 0.67 |
| BLANK | Not asked or Missing | 434,841 |  |  |

## PSATIME
<a id="psatime"></a>

**Time Since Last PSA Test**

- Module: 17.5 Prostate Cancer Screening
- Type: Num
- Column (fixed-width file): 395
- PDF page: 87
- Description: How long has it been since you had your last PSA test?
- Notes: Section 07.02, AGE, is less than 40; or Section 07.01, SEX, is coded 2; or Module 17.04, PSATEST1, is coded, 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Within the past year (anytime less than 12 months ago) | 2,287 | 62.93 | 66.23 |
| 2 | Within the past 2 years (1 year but less than 2 years ago) | 523 | 14.39 | 14.16 |
| 3 | Within the past 3 years (2 years but less than 3 years ago) | 239 | 6.58 | 5.99 |
| 4 | Within the past 5 years (3 years but less than 5 years ago) | 208 | 5.72 | 4.87 |
| 5 | 5 or more years ago | 295 | 8.12 | 6.31 |
| 7 | Don’t know/Not Sure | 77 | 2.12 | 2.32 |
| 9 | Refused | 5 | 0.14 | 0.12 |
| BLANK | Not asked or Missing | 437,822 |  |  |

## PCPSARS1
<a id="pcpsars1"></a>

**What was the MAIN reason you had this PSA test?**

- Module: 17.6 Prostate Cancer Screening
- Type: Num
- Column (fixed-width file): 396
- PDF page: 87
- Description: What was the MAIN reason you had this PSA test – was it …?
- Notes: Section 07.02, AGE, is less than 40; or Section 07.01, SEX, is coded 2; or Module 17.04, PSATEST1, is coded, 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Part of a routine exam | 2,689 | 74.06 | 75.49 |
| 2 | Because of a prostate problem | 256 | 7.05 | 6.87 |
| 3 | Because of a family history of prostate cancer | 176 | 4.85 | 5.91 |
| 4 | Because you were told you had prostate cancer | 167 | 4.60 | 3.12 |
| 5 | Some other reason | 316 | 8.70 | 7.94 |
| 7 | Don’t know/Not Sure | 20 | 0.55 | 0.50 |
| 9 | Refused | 7 | 0.19 | 0.17 |
| BLANK | Not asked or Missing | 437,825 |  |  |

## PCPSADE1
<a id="pcpsade1"></a>

**Why was PSA test done?**

- Module: 18.1 Prostate Cancer Screening Decision Making
- Type: Num
- Column (fixed-width file): 397
- PDF page: 88
- Description: Which of the following best describes the decision to have the PSA test done?
- Notes: Section 07.02, AGE, is less than 40; or Section 07.01, SEX, is coded 2; or Module 17.04, PSATEST1, is coded, 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | You made the decision alone----Go to next module | 202 | 24.66 | 26.21 |
| 2 | Your doctor, nurse, or health care provider made the decision alone----Go to next module | 275 | 33.58 | 32.42 |
| 3 | You and one or more other persons made the decision together | 247 | 30.16 | 29.55 |
| 4 | You don’t remember how the decision was made----Go to next module | 87 | 10.62 | 10.88 |
| 9 | Refused | 8 | 0.98 | 0.94 |
| BLANK | Not asked or Missing | 440,637 |  |  |

## PCDMDECN
<a id="pcdmdecn"></a>

**Who made the decision with you to have PSA test?**

- Module: 18.2 Prostate Cancer Screening Decision Making
- Type: Char
- Column (fixed-width file): 398-401
- PDF page: 88
- Description: Who made the decision with you? (Mark all that apply)
- Notes: Section 07.02, AGE, is less than 40; or Section 07.01, SEX, is coded 2; or Module 17.04, PSATEST1, is coded, 2, 7, 9, or Missing; or Module 18.01, PCPSADE1, is coded 1, 2, or 4

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Doctor/nurse/health care provider | 208 | 81.57 | 79.52 |
| 2 | Spouse/significant other | 21 | 8.24 | 9.13 |
| 3 | Other family member | 2 | 0.78 | 0.86 |
| 4 | Friend/non-relative | 5 | 1.96 | 2.60 |
| 7 | Don’t know/Not Sure | 3 | 1.18 | 1.32 |
| 9 | Refused | 4 | 1.57 | 1.45 |
| 12 - 4328 | Multiple responses | 12 | 4.71 | 5.12 |
| BLANK | Not asked or Missing | 441,201 |  |  |

## SCNTMNY1
<a id="scntmny1"></a>

**Times Past 12 Months Worried/Stressed About Having Enough Money To Pay Your Rent/Mortgage?**

- Module: 20.1 Social Context
- Type: Num
- Column (fixed-width file): 602
- PDF page: 89
- Description: How often in the past 12 months would you say you were worried or stressed about having enough money to pay your rent/mortgage? Would you say
- Notes: Section 07.08, RENTHOM1, is coded 3, 7, 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Always | 6,106 | 8.79 | 11.11 |
| 2 | Usually | 2,840 | 4.09 | 4.94 |
| 3 | Sometimes | 10,500 | 15.11 | 17.22 |
| 4 | Rarely | 11,215 | 16.14 | 17.64 |
| 5 | Never | 37,535 | 54.01 | 47.54 |
| 7 | Don’t know/Not Sure | 121 | 0.17 | 0.14 |
| 8 | Not applicable | 1,047 | 1.51 | 1.22 |
| 9 | Refused | 138 | 0.20 | 0.20 |
| BLANK | Not asked or Missing | 371,954 |  |  |

## SCNTMEL1
<a id="scntmel1"></a>

**Times Past 12 Months Worried/Stressed About Having Enough Money To Buy Nutritious Meals?**

- Module: 20.2 Social Context
- Type: Num
- Column (fixed-width file): 603
- PDF page: 89
- Description: How often in the past 12 months would you say you were worried or stressed about having enough money to buy nutritious meals? Would you say

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Always | 4,121 | 5.62 | 7.13 |
| 2 | Usually | 2,442 | 3.33 | 4.10 |
| 3 | Sometimes | 8,807 | 12.01 | 14.14 |
| 4 | Rarely | 8,850 | 12.06 | 14.18 |
| 5 | Never | 48,822 | 66.55 | 60.06 |
| 7 | Don’t know/Not Sure | 118 | 0.16 | 0.14 |
| 8 | Not applicable | 76 | 0.10 | 0.09 |
| 9 | Refused | 124 | 0.17 | 0.16 |
| BLANK | Not asked or Missing | 368,096 |  |  |

## SCNTPAID
<a id="scntpaid"></a>

**How Are You Generally Paid For The Work You Do**

- Module: 20.3 Social Context
- Type: Num
- Column (fixed-width file): 604
- PDF page: 90
- Description: At your main job or business, how are you generally paid for the work you do. Are you:
- Notes: Section 07.15, EMPLOY1, is coded 3, 4, 5, 6, 7, or 8

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Paid by salary | 13,001 | 37.41 | 32.66 |
| 2 | Paid by the hour | 16,350 | 47.04 | 51.50 |
| 3 | Paid by the job/task (e.g. commission, piecework) | 3,004 | 8.64 | 9.09 |
| 4 | Paid some other way | 1,975 | 5.68 | 5.55 |
| 7 | Don’t know/Not Sure | 172 | 0.49 | 0.48 |
| 9 | Refused | 253 | 0.73 | 0.71 |
| BLANK | Not asked or Missing | 406,701 |  |  |

## SCNTWRK1
<a id="scntwrk1"></a>

**How Many Hours Per Week Do You Work**

- Module: 20.4 Social Context
- Type: Num
- Column (fixed-width file): 605-606
- PDF page: 90
- Description: About how many hours do you work per week on all of your jobs and businesses combined?
- Notes: Section 07.15, EMPLOY1, is coded 3, 4, 5, 6, 7, or 8

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 96 | Hours (1-96 or more)----Go to next module | 33,790 | 97.28 | 97.22 |
| 97 | Don’t know/Not Sure----Go to next module | 628 | 1.81 | 1.82 |
| 98 | Zero (none)----Go to next module | 123 | 0.35 | 0.37 |
| 99 | Refused----Go to next module | 193 | 0.56 | 0.59 |
| BLANK | Not asked or Missing | 406,722 |  |  |

## SCNTLPAD
<a id="scntlpad"></a>

**How Were You Generally Paid For The Work You Did**

- Module: 20.5 Social Context
- Type: Num
- Column (fixed-width file): 607
- PDF page: 91
- Description: Thinking about the last time you worked, at your main job or business, how were you generally paid for the work you do? Were you:
- Notes: Section 07.15, EMPLOY1, is coded 1, 2, 5, 6, or 8; or Module 20.04, SCNTWRK1, is > 0

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Paid by salary | 11,342 | 44.12 | 36.20 |
| 2 | Paid by the hour | 10,853 | 42.22 | 50.41 |
| 3 | Paid by the job/task (e.g. commission, piecework) | 1,405 | 5.47 | 5.89 |
| 4 | Paid some other way | 1,371 | 5.33 | 5.01 |
| 7 | Don’t know/Not Sure | 563 | 2.19 | 1.94 |
| 9 | Refused | 171 | 0.67 | 0.55 |
| BLANK | Not asked or Missing | 415,751 |  |  |

## SCNTLWK1
<a id="scntlwk1"></a>

**How Many Hours Per Week Did You Work**

- Module: 20.6 Social Context
- Type: Num
- Column (fixed-width file): 608-609
- PDF page: 91
- Description: Thinking about the last time you worked, about how many hours did you work per week at all of your jobs and businesses combined?
- Notes: Section 07.15, EMPLOY1, is coded 1 or 2; or Module 20.04, SCNTWRK1, is > 0

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 96 | Hours (1-96 or more) | 33,709 | 87.73 | 86.35 |
| 97 | Don’t know/Not Sure | 2,580 | 6.71 | 6.26 |
| 98 | Zero (none) | 1,932 | 5.03 | 6.84 |
| 99 | Refused | 201 | 0.52 | 0.54 |
| BLANK | Not asked or Missing | 403,034 |  |  |

## SXORIENT
<a id="sxorient"></a>

**Sexual orientation or gender identity**

- Module: 21.1 Sexual Orientation and Gender Identity
- Type: Num
- Column (fixed-width file): 610
- PDF page: 92
- Description: Do you consider yourself to be: (We ask this question in order to better understand the health and health care needs of people with different sexual orientations.)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Straight | 157,199 | 94.13 | 92.89 |
| 2 | Lesbian or gay | 2,242 | 1.34 | 1.42 |
| 3 | Bisexual | 2,265 | 1.36 | 1.89 |
| 4 | Other | 581 | 0.35 | 0.45 |
| 7 | Don’t know/Not Sure | 1,759 | 1.05 | 1.43 |
| 9 | Refused | 2,951 | 1.77 | 1.92 |
| BLANK | Not asked or Missing | 274,459 |  |  |

## TRNSGNDR
<a id="trnsgndr"></a>

**Do you consider yourself to be transgender?**

- Module: 21.2 Sexual Orientation and Gender Identity
- Type: Num
- Column (fixed-width file): 611
- PDF page: 92
- Description: Do you consider yourself to be transgender? (If yes, ask “Do you consider yourself to be male-to-female, female-to-male, or gender non-conforming?)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes, Transgender, male-to-female | 361 | 0.22 | 0.28 |
| 2 | Yes, Transgender, female to male | 237 | 0.14 | 0.16 |
| 3 | Yes, Transgender, gender nonconforming | 154 | 0.09 | 0.13 |
| 4 | No | 163,685 | 98.07 | 97.92 |
| 7 | Don’t know/Not Sure | 946 | 0.57 | 0.66 |
| 9 | Refused | 1,524 | 0.91 | 0.85 |
| BLANK | Not asked or Missing | 274,549 |  |  |

## RCSGENDR
<a id="rcsgendr"></a>

**Gender of child**

- Module: 22.2 Random Child Selection
- Type: Num
- Column (fixed-width file): 618
- PDF page: 93
- Description: Is the child a boy or a girl?
- Notes: Section 07.16, CHILDREN, is coded 0, 88, 99, or Missing; or CHILDAGE > 215 months

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Boy | 29,306 | 49.16 | 47.49 |
| 2 | Girl | 27,485 | 46.11 | 43.27 |
| 9 | Refused | 2,819 | 4.73 | 9.24 |
| BLANK | Not asked or Missing | 381,846 |  |  |

## RCSRLTN2
<a id="rcsrltn2"></a>

**Relationship to child**

- Module: 22.6 Random Child Selection
- Type: Num
- Column (fixed-width file): 655
- PDF page: 93
- Description: How are you related to the child?
- Notes: Due to the nature of the data or the size of the table for display, this data is not printed for this report Section 07.16, CHILDREN, is coded 0, 88, 99, or Missing; or CHILDAGE > 215 months

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Parent (include biologic, step, or adoptive parent) | 46,509 | 78.28 | 71.05 |
| 2 | Grandparent | 5,003 | 8.42 | 6.43 |
| 3 | Foster parent or guardian | 693 | 1.17 | 0.93 |
| 4 | Sibling (include biologic, step, and adoptive sibling) | 2,711 | 4.56 | 7.89 |
| 5 | Other relative | 1,376 | 2.32 | 3.41 |
| 6 | Not related in any way | 878 | 1.48 | 1.71 |
| 7 | Don’t know/Not sure | 33 | 0.06 | 0.08 |
| 9 | Refused | 2,213 | 3.72 | 8.49 |
| BLANK | Not asked or Missing | 382,040 |  |  |

## CASTHDX2
<a id="casthdx2"></a>

**Hlth pro ever said child has asthma**

- Module: 23.1 Childhood Asthma Prevalence
- Type: Num
- Column (fixed-width file): 656
- PDF page: 94
- Description: Has a doctor, nurse or other health professional EVER said that the child has asthma?
- Notes: Section 07.16, CHILDREN, is coded 0, 88, 99, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 6,508 | 12.44 | 11.93 |
| 2 | No----Go to next module | 43,301 | 82.79 | 78.12 |
| 7 | Don’t know/Not Sure----Go to next module | 555 | 1.06 | 1.19 |
| 9 | Refused----Go to next module | 1,941 | 3.71 | 8.76 |
| BLANK | Not asked or Missing | 389,151 |  |  |

## CASTHNO2
<a id="casthno2"></a>

**Child still have asthma?**

- Module: 23.2 Childhood Asthma Prevalence
- Type: Num
- Column (fixed-width file): 657
- PDF page: 94
- Description: Does the child still have asthma?
- Notes: Section 07.16, CHILDREN, is coded 0, 88, 99, or Missing; or Module 23.01, CASTHDX2, is coded 2, 7, 9, or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 4,259 | 65.49 | 63.75 |
| 2 | No | 2,087 | 32.09 | 33.41 |
| 7 | Don’t know/Not Sure | 155 | 2.38 | 2.80 |
| 9 | Refused | 2 | 0.03 | 0.04 |
| BLANK | Not asked or Missing | 434,953 |  |  |

## EMTSUPRT
<a id="emtsuprt"></a>

**How often get emotional support needed**

- Module: 24.1 Emotional Support and Life Satisfaction
- Type: Num
- Column (fixed-width file): 658
- PDF page: 94
- Description: How often do you get the social and emotional support you need?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Always | 10,748 | 53.57 | 53.93 |
| 2 | Usually | 5,632 | 28.07 | 27.20 |
| 3 | Sometimes | 2,065 | 10.29 | 10.31 |
| 4 | Rarely | 596 | 2.97 | 3.41 |
| 5 | Never | 692 | 3.45 | 3.61 |
| 7 | Don’t know/Not sure | 232 | 1.16 | 1.10 |
| 9 | Refused | 99 | 0.49 | 0.44 |
| BLANK | Not asked or Missing | 421,392 |  |  |

## LSATISFY
<a id="lsatisfy"></a>

**Satisfaction with life**

- Module: 24.2 Emotional Support and Life Satisfaction
- Type: Num
- Column (fixed-width file): 659
- PDF page: 95
- Description: In general, how satisfied are you with your life?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Very satisfied | 9,066 | 45.21 | 43.79 |
| 2 | Satisfied | 9,721 | 48.48 | 50.17 |
| 3 | Dissatisfied | 827 | 4.12 | 3.86 |
| 4 | Very dissatisfied | 224 | 1.12 | 1.07 |
| 7 | Don’t know/Not sure | 133 | 0.66 | 0.70 |
| 9 | Refused | 81 | 0.40 | 0.41 |
| BLANK | Not asked or Missing | 421,404 |  |  |

## ADPLEASR
<a id="adpleasr"></a>

**Days had little pleasure doing things**

- Module: 25.1 Anxiety and Depression
- Type: Num
- Column (fixed-width file): 660-661
- PDF page: 95
- Description: Over the last 2 weeks, how many days have you had little interest or pleasure in doing things?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 14 | 01-14 days | 6,069 | 29.68 | 33.34 |
| 88 | None | 13,663 | 66.83 | 63.14 |
| 77 | Don’t know/Not sure | 594 | 2.91 | 3.13 |
| 99 | Refused | 119 | 0.58 | 0.39 |
| BLANK | Not asked or Missing | 421,011 |  |  |

## ADDOWN
<a id="addown"></a>

**Days felt down, depressed or hopeless**

- Module: 25.2 Anxiety and Depression
- Type: Num
- Column (fixed-width file): 662-663
- PDF page: 95
- Description: Over the last 2 weeks, how many days have you felt down, depressed or hopeless?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 14 | 01-14 days | 5,219 | 25.55 | 28.89 |
| 88 | None | 14,962 | 73.24 | 69.87 |
| 77 | Don’t know/Not sure | 185 | 0.91 | 0.92 |
| 99 | Refused | 63 | 0.31 | 0.31 |
| BLANK | Not asked or Missing | 421,027 |  |  |

## ADSLEEP
<a id="adsleep"></a>

**Days had trouble with sleep**

- Module: 25.3 Anxiety and Depression
- Type: Num
- Column (fixed-width file): 664-665
- PDF page: 96
- Description: Over the last 2 weeks, how many days have you had trouble falling asleep or staying asleep or sleeping too much?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 14 | 01-14 days | 9,317 | 45.63 | 48.02 |
| 88 | None | 10,788 | 52.83 | 50.53 |
| 77 | Don’t know/Not sure | 256 | 1.25 | 1.21 |
| 99 | Refused | 58 | 0.28 | 0.24 |
| BLANK | Not asked or Missing | 421,037 |  |  |

## ADENERGY
<a id="adenergy"></a>

**Days were tired or had little energy**

- Module: 25.4 Anxiety and Depression
- Type: Num
- Column (fixed-width file): 666-667
- PDF page: 96
- Description: Over the last 2 weeks, how many days have you felt tired or had little energy?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 14 | 01-14 days | 12,232 | 59.92 | 63.51 |
| 88 | None | 7,776 | 38.09 | 34.81 |
| 77 | Don’t know/Not sure | 339 | 1.66 | 1.42 |
| 99 | Refused | 66 | 0.32 | 0.26 |
| BLANK | Not asked or Missing | 421,043 |  |  |

## ADEAT1
<a id="adeat1"></a>

**Days ate too little or too much**

- Module: 25.5 Anxiety and Depression
- Type: Num
- Column (fixed-width file): 668-669
- PDF page: 96
- Description: Over the last 2 weeks, how many days have you had a poor appetite or eaten too much?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 14 | 01-14 days | 7,044 | 34.53 | 36.47 |
| 88 | None | 12,998 | 63.71 | 61.81 |
| 77 | Don’t know/Not sure | 302 | 1.48 | 1.51 |
| 99 | Refused | 58 | 0.28 | 0.22 |
| BLANK | Not asked or Missing | 421,054 |  |  |

## ADFAIL
<a id="adfail"></a>

**Days felt like failure or let family down**

- Module: 25.6 Anxiety and Depression
- Type: Num
- Column (fixed-width file): 670-671
- PDF page: 97
- Description: Over the last 2 weeks, how many days have you felt bad about yourself or that you were a failure or had let yourself or your family down?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 14 | 01-14 days | 3,478 | 17.05 | 20.51 |
| 88 | None | 16,682 | 81.79 | 78.33 |
| 77 | Don’t know/Not sure | 160 | 0.78 | 0.79 |
| 99 | Refused | 75 | 0.37 | 0.37 |
| BLANK | Not asked or Missing | 421,061 |  |  |

## ADTHINK
<a id="adthink"></a>

**Days had trouble concentrating**

- Module: 25.7 Anxiety and Depression
- Type: Num
- Column (fixed-width file): 672-673
- PDF page: 97
- Description: Over the last 2 weeks, how many days have you had trouble concentrating on things, such as reading the newspaper or watching the TV?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 14 | 01-14 days | 2,998 | 14.71 | 17.81 |
| 88 | None | 17,156 | 84.18 | 81.04 |
| 77 | Don’t know/Not sure | 175 | 0.86 | 0.91 |
| 99 | Refused | 52 | 0.26 | 0.24 |
| BLANK | Not asked or Missing | 421,075 |  |  |

## ADMOVE
<a id="admove"></a>

**Days talked to move slower or faster than usual**

- Module: 25.8 Anxiety and Depression
- Type: Num
- Column (fixed-width file): 674-675
- PDF page: 97
- Description: Over the last 2 weeks, how many days have you moved or spoken so slowly that other people could have noticed? Or the opposite – being so fidgety or restless that you were moving around a lot more than usual?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 14 | 01-14 days | 2,213 | 10.87 | 13.10 |
| 88 | None | 17,705 | 86.94 | 84.56 |
| 77 | Don’t know/Not sure | 394 | 1.93 | 2.09 |
| 99 | Refused | 53 | 0.26 | 0.25 |
| BLANK | Not asked or Missing | 421,091 |  |  |

## MISTMNT
<a id="mistmnt"></a>

**Receiving medicine or treatment from health pro for emotional problem**

- Module: 25.9 Anxiety and Depression
- Type: Num
- Column (fixed-width file): 676
- PDF page: 98
- Description: Are you now taking medicine or receiving treatment from a doctor or other health professional for any type of mental health condition or emotional problem?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 2,989 | 14.69 | 14.15 |
| 2 | No | 17,273 | 84.88 | 85.39 |
| 7 | Don’t know/Not sure | 44 | 0.22 | 0.21 |
| 9 | Refused | 44 | 0.22 | 0.25 |
| BLANK | Not asked or Missing | 421,106 |  |  |

## ADANXEV
<a id="adanxev"></a>

**Ever told you had an anxiety disorder**

- Module: 25.10 Anxiety and Depression
- Type: Num
- Column (fixed-width file): 677
- PDF page: 98
- Description: Has a doctor or other healthcare provider EVER told you that you had an anxiety disorder (including acute stress disorder, anxiety, generalized anxiety disorder, obsessive-compulsive disorder, panic disorder, phobia, posttraumatic stress disorder, or social anxiety disorder)?

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 3,294 | 16.19 | 18.21 |
| 2 | No | 16,919 | 83.17 | 81.06 |
| 7 | Don’t know/Not sure | 91 | 0.45 | 0.54 |
| 9 | Refused | 38 | 0.19 | 0.19 |
| BLANK | Not asked or Missing | 421,114 |  |  |

## QSTVER
<a id="qstver"></a>

**Questionnaire Version Identifier**

- State: 1.1 Questionnaire Version
- Type: Num
- Column (fixed-width file): 682-683
- PDF page: 99
- Description: Questionnaire Version Identifier

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 10 | Landline single questionnaire | 150,457 | 34.08 | 20.09 |
| 11 | Landline multiple questionnaire version 1 | 52,636 | 11.92 | 8.80 |
| 12 | Landline multiple questionnaire version 2 | 47,346 | 10.72 | 8.19 |
| 13 | Landline multiple questionnaire version 3 | 4,206 | 0.95 | 1.74 |
| 20 | Cell Phone single questionnaire | 111,274 | 25.21 | 32.71 |
| 21 | Cell Phone multiple questionnaire version 1 | 35,601 | 8.06 | 12.57 |
| 22 | Cell Phone multiple questionnaire version 2 | 33,987 | 7.70 | 11.94 |
| 23 | Cell Phone multiple questionnaire version 3 | 5,949 | 1.35 | 3.98 |

## QSTLANG
<a id="qstlang"></a>

**Language identifier**

- State: 1.1 Questionnaire Language
- Type: Num
- Column (fixed-width file): 684-685
- PDF page: 99
- Description: Language identifier

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | English | 425,069 | 96.29 | 92.13 |
| 2 | Spanish | 16,356 | 3.71 | 7.87 |
| 3 - 99 | Other | 9 | 0.00 | 0.00 |
| BLANK | Missing | 22 |  |  |

## EXACTOT1
<a id="exactot1"></a>

**First Activity Other response description**

- Section: 11.3 Exercise (Physical Activity)
- Type: Char
- Column (fixed-width file): 841-860
- PDF page: 99
- Description: First Activity Other response description

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## EXACTOT2
<a id="exactot2"></a>

**Second Activity Other response description**

- Section: 11.7 Exercise (Physical Activity)
- Type: Char
- Column (fixed-width file): 861-880
- PDF page: 100
- Description: Second Activity Other response description

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## MSCODE
<a id="mscode"></a>

**Metropolitan Status Code**

- Weighting: 1.2 Weighting Variables
- Type: Num
- Column (fixed-width file): 1406
- PDF page: 100
- Description: Metropolitan Status Code

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | In the center city of an MSA | 111,864 | 44.64 | 50.14 |
| 2 | Outside the center city of an MSA but inside the county containing the center city | 44,086 | 17.59 | 24.81 |
| 3 | Inside a suburban county of the MSA | 18,099 | 7.22 | 7.05 |
| 5 | Not in an MSA | 76,530 | 30.54 | 18.01 |
| BLANK | GU, PR, VI | 190,877 |  |  |

## _STSTR
<a id="ststr"></a>

**Sample Design Stratification Variable**

- Weighting: 1.3 Weighting Variables
- Type: Num
- Column (fixed-width file): 1407-1412
- PDF page: 100
- Description: Sample Design Stratification Variable (A five digit number that combines the values for _STATE (first two characters), _GEOSTR (third and fourth character), and _DENSTR2 (final character).)
- Notes: Floating Decimal Point. Due to the nature of the data or the size of the table for display, this data is not printed for this report

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## _STRWT
<a id="strwt"></a>

**Stratum weight**

- Weighting: 1.4 Weighting Variables
- Type: Num
- Column (fixed-width file): 1413-1422
- PDF page: 101
- Description: Stratum weight (Number of records in a stratum (NRECSTR) divided by the number of records selected (NRECSEL).)
- Notes: Floating Decimal Point. Due to the nature of the data or the size of the table for display, this data is not printed for this report

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## _RAWRAKE
<a id="rawrake"></a>

**Raw weighting factor used in raking**

- Weighting: 1.7 Weighting Variables
- Type: Num
- Column (fixed-width file): 1443-1452
- PDF page: 101
- Description: Raw weighting factor used in raking (Number of adults in the household (NUMADULT, maximum of 5) divided by the imputed number of phones (_IMPNPH, maximum of 3).)
- Notes: Floating Decimal Point. Due to the nature of the data or the size of the table for display, this data is not printed for this report

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## _WT2RAKE
<a id="wt2rake"></a>

**Design weight use in raking**

- Weighting: 1.8 Weighting Variables
- Type: Num
- Column (fixed-width file): 1453-1462
- PDF page: 101
- Description: Design weight used in raking (Stratum weight (_STRWT) multiplied by the raw weighting factor (_RAWRAKE).)
- Notes: Floating Decimal Point. Due to the nature of the data or the size of the table for display, this data is not printed for this report

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## _CHISPNC
<a id="chispnc"></a>

**Child Hispanic, Latino/a, or Spanish origin calculated variable**

- ChildDemographics: 1.01 Child Demographic Variables
- Type: Num
- Column (fixed-width file): 1478
- PDF page: 102
- Description: Child Hispanic, Latino/a, or Spanish origin calculated variable

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Child of Hispanic, Latino/a, or Spanish origin | 10,571 | 3.31 | 6.90 |
| 2 | Child not of Hispanic, Latino/a, or Spanish origin | 51,296 | 16.05 | 17.89 |
| 9 | Don’t know/Not Sure/Refused | 257,768 | 80.64 | 75.21 |
| BLANK | Not asked or Missing | 121,821 |  |  |

## _CRACE1
<a id="crace1"></a>

**Child Non-Hispanic Race including Multiracial**

- ChildDemographics: 1.04 Child Demographic Variables
- Type: Num
- Column (fixed-width file): 1535-1536
- PDF page: 102
- Description: Child multiracial race categorization

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | White only | 46,797 | 71.85 | 64.19 |
| 2 | Black or African American only | 5,856 | 8.99 | 11.31 |
| 3 | American Indian or Alaskan Native only | 1,735 | 2.66 | 1.88 |
| 4 | Asian Only | 1,840 | 2.83 | 4.48 |
| 5 | Native Hawaiian or other Pacific Islander only | 216 | 0.33 | 0.34 |
| 6 | Other race only | 1,765 | 2.71 | 3.57 |
| 7 | Multiracial | 3,054 | 4.69 | 3.67 |
| 77 | Don’t know/Not sure | 706 | 1.08 | 1.20 |
| 99 | Refused | 3,160 | 4.85 | 9.36 |
| BLANK | Missing | 376,327 |  |  |

## _CPRACE
<a id="cprace"></a>

**Preferred Child Race Categories**

- ChildDemographics: 1.05 Child Demographic Variables
- Type: Num
- Column (fixed-width file): 1537-1538
- PDF page: 103
- Description: Preferred Child Race Categories

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | White | 46,797 | 71.85 | 64.19 |
| 2 | Black or African American | 5,856 | 8.99 | 11.31 |
| 3 | American Indian or Alaskan Native | 1,735 | 2.66 | 1.88 |
| 4 | Asian | 1,840 | 2.83 | 4.48 |
| 5 | Native Hawaiian or other Pacific Islander | 216 | 0.33 | 0.34 |
| 6 | Other race | 1,765 | 2.71 | 3.57 |
| 7 | No preferred race | 3,054 | 4.69 | 3.67 |
| 77 | Don’t know/Not sure | 706 | 1.08 | 1.20 |
| 99 | Refused | 3,160 | 4.85 | 9.36 |
| BLANK | Missing | 376,327 |  |  |

## _CLLCPWT
<a id="cllcpwt"></a>

**Final child weight: Land-line and Cell-Phone data**

- ChildLandandCellRaking: 1.5 Child Weighting Variables
- Type: Num
- Column (fixed-width file): 1580-1589
- PDF page: 103
- Description: Final child weight: Land-line and Cell-Phone data (Raking derived weight)
- Notes: Floating Decimal Point. Due to the nature of the data or the size of the table for display, this data is not printed for this report

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## _DUALUSE
<a id="dualuse"></a>

**Dual Phone Use Categories**

- LandandCellRaking: 1.2 Weighting Variables
- Type: Num
- Column (fixed-width file): 1677
- PDF page: 103
- Description: Dual Phone Use Categories

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Landline frame with a cell phone | 205,310 | 46.51 | 31.38 |
| 2 | Cell phone frame with a landline | 70,341 | 15.93 | 16.14 |
| 9 | No Dual Phone Use | 165,805 | 37.56 | 52.48 |

## _DUALCOR
<a id="dualcor"></a>

**Dual Phone Use Correction Factor**

- LandandCellRaking: 1.3 Weighting Variables
- Type: Num
- Column (fixed-width file): 1678-1687
- PDF page: 104
- Description: Dual phone use correction factor
- Notes: Due to the nature of the data or the size of the table for display, this data is not printed for this report

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## _LLCPWT
<a id="llcpwt"></a>

**Final weight: Land-line and cell-phone data**

- LandandCellRaking: 1.21 Weighting Variables
- Type: Num
- Column (fixed-width file): 1746-1755
- PDF page: 104
- Description: Final weight assigned to each respondent: Land-line and cell-phone data (Raking derived weight)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| HIDDEN | Data not displayed | 441,456 | 100.00 | 100.00 |

## _RFHLTH
<a id="rfhlth"></a>

**Adults with good or better health**

- CalculatedVariables: 1.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 1894
- PDF page: 104
- Description: Adults with good or better health
- Notes: GENHLTH = 1 or 2 or 3 GENHLTH = 4 or 5 GENHLTH = 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Good or Better Health | 358,072 | 81.11 | 82.05 |
| 2 | Fair or Poor Health | 82,137 | 18.61 | 17.66 |
| 9 | Don’t know/Not Sure Or Refused/Missing | 1,247 | 0.28 | 0.29 |

## _HCVU651
<a id="hcvu651"></a>

**Respondents aged 18-64 with health care coverage**

- CalculatedVariables: 3.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 1895
- PDF page: 105
- Description: Respondents aged 18-64 who have any form of health care coverage
- Notes: 18 <= AGE <=64 and HLTHPLN1 = 1 18 <= AGE <=64 and HLTHPLN1 = 2 AGE > 64 or AGE = Missing or HLTHPLN1 = 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Have health care coverage | 252,542 | 57.21 | 67.27 |
| 2 | Do not have health care coverage | 29,661 | 6.72 | 11.67 |
| 9 | Don’t know/Not Sure, Refused or Missing | 159,253 | 36.07 | 21.05 |

## _RFHYPE5
<a id="rfhype5"></a>

**High Blood Pressure Calculated Variable**

- CalculatedVariables: 4.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 1896
- PDF page: 105
- Description: Adults who have been told they have high blood pressure by a doctor, nurse, or other health professional
- Notes: BPHIGH4 = 2 or 3 or 4 BPHIGH4 = 1 BPHIGH4 = 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No | 261,901 | 59.33 | 67.78 |
| 2 | Yes | 178,188 | 40.36 | 31.90 |
| 9 | Don’t know/Not Sure/Refused/Missing | 1,367 | 0.31 | 0.31 |

## _CHOLCHK
<a id="cholchk"></a>

**Cholesterol Checked Calculated Variable**

- CalculatedVariables: 5.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 1897
- PDF page: 105
- Description: Cholesterol check within past five years
- Notes: BLOODCHO = 1 and CHOLCHK = 1 or 2 or 3 BLOODCHO = 1 and CHOLCHK = 4 BLOODCHO = 2 BLOODCHO = 7 or 9 or Missing or CHOLCHK = 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Had cholesterol checked in past 5 years | 362,923 | 82.21 | 74.83 |
| 2 | Did not have cholesterol checked in past 5 years | 13,523 | 3.06 | 3.15 |
| 3 | Have never had cholesterol checked | 49,673 | 11.25 | 18.04 |
| 9 | Don’t know/Not Sure Or Refused/Missing | 15,337 | 3.47 | 3.98 |

## _RFCHOL
<a id="rfchol"></a>

**High Cholesterol Calculated Variable**

- CalculatedVariables: 5.2 Calculated Variables
- Type: Num
- Column (fixed-width file): 1898
- PDF page: 106
- Description: Adults who have had their cholesterol checked and have been told by a doctor, nurse, or other health professional that it was high
- Notes: BLOODCHO=1 and TOLDHI2 = 2 BLOODCHO=1 and TOLDHI2 = 1 BLOODCHO=1 and TOLDHI2 = 7 or 9 or Missing BLOODCHO = 2 or 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No | 218,771 | 57.22 | 62.97 |
| 2 | Yes | 159,970 | 41.84 | 36.19 |
| 9 | Don’t know/Not Sure Or Refused/Missing | 3,561 | 0.93 | 0.84 |
| BLANK | Missing | 59,154 |  |  |

## _MICHD
<a id="michd"></a>

**Ever had CHD or MI**

- CalculatedVariables: 6.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 1899
- PDF page: 106
- Description: Respondents that have ever reported having coronary heart disease (CHD) or myocardial infarction (MI)
- Notes: CVDINFR4=1 OR CVDCRHD4=1 CVDINFR4=2 AND CVDCRHD4=2 CVDINFR4=7, 9 OR MISSING OR CVDCRHD4=7, 9, OR MISSING

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Reported having MI or CHD | 38,633 | 8.83 | 6.42 |
| 2 | Did not report having MI or CHD | 398,881 | 91.17 | 93.58 |
| BLANK | Not asked or Missing | 3,942 |  |  |

## _LTASTH1
<a id="ltasth1"></a>

**Lifetime Asthma Calculated Variable**

- CalculatedVariables: 6.2 Calculated Variables
- Type: Num
- Column (fixed-width file): 1900
- PDF page: 106
- Description: Adults who have ever been told they have asthma
- Notes: ASTHMA3 = 2 ASTHMA3 = 1 ASTHMA3 = 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No | 380,554 | 86.20 | 85.88 |
| 2 | Yes | 59,409 | 13.46 | 13.80 |
| 9 | Don’t know/Not Sure Or Refused/Missing | 1,493 | 0.34 | 0.32 |

## _CASTHM1
<a id="casthm1"></a>

**Current Asthma Calculated Variable**

- CalculatedVariables: 6.3 Calculated Variables
- Type: Num
- Column (fixed-width file): 1901
- PDF page: 107
- Description: Adults who have been told they currently have asthma
- Notes: ASTHMA3 = 2 or ASTHMA3 = 1 and ASTHNOW = 2 ASTHMA3 = 1 and ASTHNOW = 1 ASTHMA3 = 7 or 9 or Missing or ASTHNOW = 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No | 398,154 | 90.19 | 90.48 |
| 2 | Yes | 40,000 | 9.06 | 8.77 |
| 9 | Don’t know/Not Sure Or Refused/Missing | 3,302 | 0.75 | 0.75 |

## _ASTHMS1
<a id="asthms1"></a>

**Computed Asthma Status**

- CalculatedVariables: 6.4 Calculated Variables
- Type: Num
- Column (fixed-width file): 1902
- PDF page: 107
- Description: Computed asthma status
- Notes: ASTHMA3 = 1 and ASTHNOW = 1 ASTHMA3 = 1 and ASTHNOW = 2 ASTHMA3 = 2 ASTHMA3 = 7 or 9 or Missing or ASTHNOW = 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Current | 40,000 | 9.06 | 8.77 |
| 2 | Former | 17,600 | 3.99 | 4.60 |
| 3 | Never | 380,554 | 86.20 | 85.88 |
| 9 | Don’t know/Not Sure Or Refused/Missing | 3,302 | 0.75 | 0.75 |

## _DRDXAR1
<a id="drdxar1"></a>

**Respondents diagnosed with arthritis**

- CalculatedVariables: 6.5 Calculated Variables
- Type: Num
- Column (fixed-width file): 1903
- PDF page: 107
- Description: Respondents who have had a doctor diagnose them as having some form of arthritis
- Notes: HAVARTH3 = 1 HAVARTH3 = 2 HAVARTH3 = 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Diagnosed with arthritis | 148,036 | 33.75 | 24.68 |
| 2 | Not diagnosed with arthritis | 290,621 | 66.25 | 75.32 |
| BLANK | Don´t know/Not Sure/Refused/Missing | 2,799 |  |  |

## _PRACE1
<a id="prace1"></a>

**Computed Preferred Race**

- CalculatedVariables: 7.3 Calculated Race Variables
- Type: Num
- Column (fixed-width file): 1960-1961
- PDF page: 108
- Description: Preferred race category
- Notes: MRACASC1 = 10 MRACASC1 = 20 MRACASC1 = 30 MRACASC1 = 40,41,42,43,44,45,46,47 MRACASC1 = 50,51,52,53,54 MRACASC1 = 60 MRACASC1 >= 100 and ORACE3 = 7 or 9 MRACASC1 >= 100 and ORACE3 = 8 or Missing MRACASC1 = 77 MRACASC1 = 99

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | White | 363,201 | 82.27 | 73.68 |
| 2 | Black or African American | 36,873 | 8.35 | 12.53 |
| 3 | American Indian or Alaskan Native | 8,722 | 1.98 | 1.91 |
| 4 | Asian | 10,894 | 2.47 | 5.17 |
| 5 | Native Hawaiian or other Pacific Islander | 2,901 | 0.66 | 0.42 |
| 6 | Other race | 8,905 | 2.02 | 3.26 |
| 7 | No preferred race | 1,138 | 0.26 | 0.27 |
| 8 | Multiracial but preferred race not answered | 7 | 0.00 | 0.00 |
| 77 | Don’t know/Not sure | 3,475 | 0.79 | 1.35 |
| 99 | Refused | 5,340 | 1.21 | 1.40 |

## _MRACE1
<a id="mrace1"></a>

**Calculated non-Hispanic Race including multiracial**

- CalculatedVariables: 7.4 Calculated Race Variables
- Type: Num
- Column (fixed-width file): 1962-1963
- PDF page: 109
- Description: Calculated multiracial race categorization
- Notes: MRACASC1 = 10 MRACASC1 = 20 MRACASC1 = 30 MRACASC1 = 40,41,42,43,44,45,46,47 MRACASC1 = 50,51,52,53,54 MRACASC1 = 60 MRACASC1 >= 100 MRACASC1 = 77 MRACASC1 = 99

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | White only | 359,173 | 81.36 | 72.99 |
| 2 | Black or African American only | 35,908 | 8.13 | 12.24 |
| 3 | American Indian or Alaskan Native only | 7,942 | 1.80 | 1.78 |
| 4 | Asian Only | 10,117 | 2.29 | 5.05 |
| 5 | Native Hawaiian or other Pacific Islander only | 1,743 | 0.39 | 0.32 |
| 6 | Other race only | 8,673 | 1.96 | 3.19 |
| 7 | Multiracial | 9,085 | 2.06 | 1.68 |
| 77 | Don’t know/Not sure | 3,475 | 0.79 | 1.35 |
| 99 | Refused | 5,340 | 1.21 | 1.40 |

## _HISPANC
<a id="hispanc"></a>

**Hispanic, Latino/a, or Spanish origin calculated variable**

- CalculatedVariables: 7.6 Calculated Race Variables
- Type: Num
- Column (fixed-width file): 1966
- PDF page: 109
- Description: Hispanic, Latino/a, or Spanish origin calculated variable

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Hispanic, Latino/a, or Spanish origin | 35,795 | 8.11 | 16.36 |
| 2 | Not of Hispanic, Latino/a, or Spanish origin | 401,525 | 90.95 | 82.69 |
| 9 | Don´t Know, Refused or Missing | 4,136 | 0.94 | 0.95 |

## _RACE
<a id="race"></a>

**Computed Race-Ethnicity grouping**

- CalculatedVariables: 7.7 Calculated Race Variables
- Type: Num
- Column (fixed-width file): 1967
- PDF page: 110
- Description: Race/ethnicity categories
- Notes: _HISPANC = 2 and _MRACE1 = 10 _HISPANC = 2 and _MRACE1 = 20 _HISPANC = 2 and _MRACE1 = 33 _HISPANC = 2 and _MRACE1 = 40,41,42,43,44,45,46,47 _HISPANC = 2 and _MRACE1 = 50,51,52,53,54 _HISPANC = 2 and _MRACE1 = 60 _HISPANC = 2 and _MRACE1 = 77 _HISPANC = 1 _HISPANC = 7 or 9 or _MRACE1 = 77 or 99 and _HISPANC = 2

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | White only, non-Hispanic | 336,066 | 76.13 | 62.55 |
| 2 | Black only, non-Hispanic | 34,346 | 7.78 | 11.55 |
| 3 | American Indian or Alaskan Native only, Non-Hispanic | 6,546 | 1.48 | 0.98 |
| 4 | Asian only, non-Hispanic | 9,759 | 2.21 | 4.89 |
| 5 | Native Hawaiian or other Pacific Islander only, Non-Hispanic | 1,406 | 0.32 | 0.19 |
| 6 | Other race only, non-Hispanic | 1,945 | 0.44 | 0.41 |
| 7 | Multiracial, non-Hispanic | 8,156 | 1.85 | 1.39 |
| 8 | Hispanic | 35,795 | 8.11 | 16.36 |
| 9 | Don’t know/Not sure/Refused | 7,437 | 1.68 | 1.68 |

## _RACEG21
<a id="raceg21"></a>

**Create Computed Non-Hispanic Whites/All Others Race Categories Race/Ethnic Group Codes Used In Post-Stratification Variable**

- CalculatedVariables: 7.8 Calculated Race Variables
- Type: Num
- Column (fixed-width file): 1968
- PDF page: 110
- Description: White non-Hispanic race group
- Notes: _RACE = 1 _RACE = 2 or 3 or 4 or 5 or 6 or 7 or 8 _RACE = 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Non-Hispanic White | 336,066 | 76.13 | 62.55 |
| 2 | Non-White or Hispanic | 97,953 | 22.19 | 35.76 |
| 9 | Don’t know/Not sure/Refused | 7,437 | 1.68 | 1.68 |

## _RACEGR3
<a id="racegr3"></a>

**Computed Five level race/ethnicity category.**

- CalculatedVariables: 7.9 Calculated Race Variables
- Type: Num
- Column (fixed-width file): 1969
- PDF page: 111
- Description: Five-level race/ethnicity category

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | White only, Non-Hispanic | 336,066 | 76.13 | 62.55 |
| 2 | Black only, Non-Hispanic | 34,346 | 7.78 | 11.55 |
| 3 | Other race only, Non-Hispanic | 19,656 | 4.45 | 6.47 |
| 4 | Multiracial, Non-Hispanic | 8,156 | 1.85 | 1.39 |
| 5 | Hispanic | 35,795 | 8.11 | 16.36 |
| 9 | Don’t know/Not sure/Refused | 7,437 | 1.68 | 1.68 |

## _RACE_G1
<a id="race_g1"></a>

**Computed race groups used for internet prevalence tables**

- CalculatedVariables: 7.10 Calculated Race Variables
- Type: Num
- Column (fixed-width file): 1970
- PDF page: 111
- Description: Race groups used for internet prevalence tables

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | White - Non-Hispanic | 336,066 | 77.43 | 63.62 |
| 2 | Black - Non-Hispanic | 34,346 | 7.91 | 11.74 |
| 3 | Hispanic | 35,795 | 8.25 | 16.64 |
| 4 | Other race only, Non-Hispanic | 19,656 | 4.53 | 6.58 |
| 5 | Multiracial, Non-Hispanic | 8,156 | 1.88 | 1.41 |
| BLANK | Don’t know/Not sure/Refused component question | 7,437 |  |  |

## _AGEG5YR
<a id="ageg5yr"></a>

**Reported age in five-year age categories calculated variable**

- CalculatedVariables: 7.11 Calculated Variables
- Type: Num
- Column (fixed-width file): 1971-1972
- PDF page: 112
- Description: Fourteen-level age category
- Notes: 18 <= AGE <= 24 25 <= AGE <= 29 30 <= AGE <= 34 35 <= AGE <= 39 40 <= AGE <= 44 45 <= AGE <= 49 50 <= AGE <= 54 55 <= AGE <= 59 60 <= AGE <= 64 65 <= AGE <= 69 70 <= AGE <= 74 75 <= AGE <= 79 80 <= AGE <= 99 7 <= AGE <= 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Age 18 to 24 | 24,192 | 5.48 | 12.79 |
| 2 | Age 25 to 29 | 19,746 | 4.47 | 8.12 |
| 3 | Age 30 to 34 | 22,917 | 5.19 | 9.19 |
| 4 | Age 35 to 39 | 24,545 | 5.56 | 7.87 |
| 5 | Age 40 to 44 | 25,942 | 5.88 | 8.34 |
| 6 | Age 45 to 49 | 30,276 | 6.86 | 7.37 |
| 7 | Age 50 to 54 | 39,881 | 9.03 | 9.51 |
| 8 | Age 55 to 59 | 46,209 | 10.47 | 8.28 |
| 9 | Age 60 to 64 | 49,794 | 11.28 | 8.02 |
| 10 | Age 65 to 69 | 49,264 | 11.16 | 6.39 |
| 11 | Age 70 to 74 | 38,362 | 8.69 | 4.91 |
| 12 | Age 75 to 79 | 28,232 | 6.40 | 3.83 |
| 13 | Age 80 or older | 36,760 | 8.33 | 4.37 |
| 14 | Don’t know/Refused/Missing | 5,336 | 1.21 | 1.01 |

## _AGE65YR
<a id="age65yr"></a>

**Reported age in two age groups calculated variable**

- CalculatedVariables: 7.12 Calculated Variables
- Type: Num
- Column (fixed-width file): 1973
- PDF page: 112
- Description: Two-level age category
- Notes: 18 <= AGE <= 64 65 <= AGE <= 99 7 <= AGE <= 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Age 18 to 64 | 283,502 | 64.22 | 79.48 |
| 2 | Age 65 or older | 152,618 | 34.57 | 19.51 |
| 3 | Don’t know/Refused/Missing | 5,336 | 1.21 | 1.01 |

## _AGE80
<a id="age80"></a>

**Imputed Age value collapsed above 80**

- CalculatedVariables: 7.13 Calculated Variables
- Type: Num
- Column (fixed-width file): 1974-1975
- PDF page: 113
- Description: Imputed Age value collapsed above 80

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 18 - 24 | Imputed Age 18 to 24 | 24,196 | 5.48 | 12.79 |
| 25 - 29 | Imputed Age 25 to 29 | 19,755 | 4.47 | 8.12 |
| 30 - 34 | Imputed Age 30 to 34 | 22,964 | 5.20 | 9.21 |
| 35 - 39 | Imputed Age 35 to 39 | 24,643 | 5.58 | 7.94 |
| 40 - 44 | Imputed Age 40 to 44 | 26,176 | 5.93 | 8.46 |
| 45 - 49 | Imputed Age 45 to 49 | 31,399 | 7.11 | 7.67 |
| 50 - 54 | Imputed Age 50 to 54 | 40,512 | 9.18 | 9.63 |
| 55 - 59 | Imputed Age 55 to 59 | 46,625 | 10.56 | 8.34 |
| 60 - 64 | Imputed Age 60 to 64 | 51,977 | 11.77 | 8.27 |
| 65 - 69 | Imputed Age 65 to 69 | 49,826 | 11.29 | 6.46 |
| 70 - 74 | Imputed Age 70 to 74 | 38,384 | 8.69 | 4.92 |
| 75 - 79 | Imputed Age 75 to 79 | 28,235 | 6.40 | 3.83 |
| 80 - 99 | Imputed Age 80 or older | 36,764 | 8.33 | 4.37 |

## _AGE_G
<a id="age_g"></a>

**Imputed age in six groups**

- CalculatedVariables: 7.14 Calculated Variables
- Type: Num
- Column (fixed-width file): 1976
- PDF page: 113
- Description: Six-level imputed age category
- Notes: 18 <= _IMPAGE <= 24 25 <= _IMPAGE <= 34 35 <= _IMPAGE <= 44 45 <= _IMPAGE <= 54 55 <= _IMPAGE <= 64 _IMPAGE => 65

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Age 18 to 24 | 24,196 | 5.48 | 12.79 |
| 2 | Age 25 to 34 | 42,719 | 9.68 | 17.33 |
| 3 | Age 35 to 44 | 50,819 | 11.51 | 16.40 |
| 4 | Age 45 to 54 | 71,911 | 16.29 | 17.30 |
| 5 | Age 55 to 64 | 98,602 | 22.34 | 16.60 |
| 6 | Age 65 or older | 153,209 | 34.71 | 19.58 |

## HTIN4
<a id="htin4"></a>

**Computed Height in Inches**

- CalculatedVariables: 7.15 Calculated Variables
- Type: Num
- Column (fixed-width file): 1977-1979
- PDF page: 114
- Description: Reported height in inches
- Notes: 0300 <= HEIGHT3 <= 0711 (metric HEIGHT3 value multiplied by 100 and divided by 2.54)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 36 - 95 | Height in inches | 424,196 | 100.00 | 100.00 |
| BLANK |  | 17,260 |  |  |

## HTM4
<a id="htm4"></a>

**Computed Height in Meters**

- CalculatedVariables: 7.16 Calculated Variables
- Type: Num
- Column (fixed-width file): 1980-1982
- PDF page: 114
- Description: Reported height in meters
- Notes: 0300 <= HEIGHT3 <= 0711 or 9091 <= HEIGHT3 <= 9244 (non-metric HEIGHT3 value multiplied by .0254)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 91 - 244 | Height in meters [2 implied decimal places] | 426,024 | 100.00 | 100.00 |
| BLANK |  | 15,432 |  |  |

## WTKG3
<a id="wtkg3"></a>

**Computed Weight in Kilograms**

- CalculatedVariables: 7.17 Calculated Variables
- Type: Num
- Column (fixed-width file): 1983-1987
- PDF page: 114
- Description: Reported weight in kilograms
- Notes: 0001 <= WEIGHT2 <= 650 or 9023 <= WEIGHT2 <= 9295 (non-metric WEIGHT2 value divided by 2.2046) WEIGHT2 = 7777 or 9999 or Missing or not in accepted values

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 2300 - 29500 | Weight in kilograms [2 implied decimal places] | 410,535 | 93.00 | 93.29 |
| 99999 | Don’t know/Refused/Missing | 30,921 | 7.00 | 6.71 |

## _BMI5
<a id="bmi5"></a>

**Computed body mass index**

- CalculatedVariables: 7.18 Calculated Variables
- Type: Num
- Column (fixed-width file): 1988-1991
- PDF page: 115
- Description: Body Mass Index (BMI)
- Notes: WTKG3/(HTM4*HTM4) (Has 2 implied decimal places) WTKG3 = 777 or 999 or HTM4 = 777 or 999

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 - 9999 | 1 or greater | 405,058 | 100.00 | 100.00 |
| BLANK | Don’t know/Refused/Missing | 36,398 |  |  |

## _BMI5CAT
<a id="bmi5cat"></a>

**Computed body mass index categories**

- CalculatedVariables: 7.19 Calculated Variables
- Type: Num
- Column (fixed-width file): 1992
- PDF page: 115
- Description: Four-categories of Body Mass Index (BMI)
- Notes: _BMI5 < 1850 (_BMI5 has 2 implied decimal places) 1850 <= _BMI5 < 2500 2500 <= _BMI5 < 3000 30000 <= _BMI5 < 9999 _BMI5 = 9999

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Underweight | 6,721 | 1.66 | 1.80 |
| 2 | Normal Weight | 131,409 | 32.44 | 33.63 |
| 3 | Overweight | 147,004 | 36.29 | 35.71 |
| 4 | Obese | 119,924 | 29.61 | 28.86 |
| BLANK | Don’t know/Refused/Missing | 36,398 |  |  |

## _RFBMI5
<a id="rfbmi5"></a>

**Overweight or obese calculated variable**

- CalculatedVariables: 7.20 Calculated Variables
- Type: Num
- Column (fixed-width file): 1993
- PDF page: 115
- Description: Adults who have a body mass index greater than 25.00 (Overweight or Obese)
- Notes: 1200 <= _BMI5 < 2500 (_BMI5 has 2 implied decimal places) 2500 <= _BMI5 < 9999 _BMI5 = 9999

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No | 138,130 | 31.29 | 32.31 |
| 2 | Yes | 266,928 | 60.47 | 58.87 |
| 9 | Don’t know/Refused/Missing | 36,398 | 8.24 | 8.82 |

## _CHLDCNT
<a id="chldcnt"></a>

**Computed number of children in household**

- CalculatedVariables: 7.21 Calculated Variables
- Type: Num
- Column (fixed-width file): 1994
- PDF page: 116
- Description: Number of children in household
- Notes: CHILDREN = 88 CHILDREN = 01 CHILDREN = 02 CHILDREN = 03 CHILDREN = 04 05 <= CHILDREN < 88 CHILDREN = 99

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No children in household | 324,000 | 73.39 | 62.57 |
| 2 | One child in household | 46,376 | 10.51 | 15.02 |
| 3 | Two children in household | 40,614 | 9.20 | 12.86 |
| 4 | Three children in household | 17,313 | 3.92 | 5.60 |
| 5 | Four children in household | 6,371 | 1.44 | 1.92 |
| 6 | Five or more children in household | 3,145 | 0.71 | 1.01 |
| 9 | Don’t know/Not sure/Missing | 3,637 | 0.82 | 1.03 |

## _EDUCAG
<a id="educag"></a>

**Computed level of education completed categories**

- CalculatedVariables: 7.22 Calculated Variables
- Type: Num
- Column (fixed-width file): 1995
- PDF page: 116
- Description: Level of education completed
- Notes: EDUCA = 1 or 2 or 3 EDUCA = 4 EDUCA = 5 EDUCA = 6 EDUCA = 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Did not graduate High School | 34,259 | 7.76 | 14.29 |
| 2 | Graduated High School | 123,227 | 27.91 | 28.19 |
| 3 | Attended College or Technical School | 120,528 | 27.30 | 30.88 |
| 4 | Graduated from College or Technical School | 161,631 | 36.61 | 26.21 |
| 9 | Don’t know/Not sure/Missing | 1,811 | 0.41 | 0.42 |

## _INCOMG
<a id="incomg"></a>

**Computed income categories**

- CalculatedVariables: 7.23 Calculated Variables
- Type: Num
- Column (fixed-width file): 1996
- PDF page: 117
- Description: Income categories
- Notes: INCOME2 = 1 or 2 INCOME2 = 3 or 4 INCOME2 = 5 INCOME2 = 6 INCOME2 = 7 or 8 INCOME2 = 77 or 99 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Less than $15,000 | 38,048 | 8.62 | 9.54 |
| 2 | $15,000 to less than $25,000 | 59,174 | 13.40 | 14.07 |
| 3 | $25,000 to less than $35,000 | 39,235 | 8.89 | 8.70 |
| 4 | $35,000 to less than $50,000 | 52,052 | 11.79 | 11.25 |
| 5 | $50,000 or more | 173,442 | 39.29 | 38.88 |
| 9 | Don’t know/Not sure/Missing | 79,505 | 18.01 | 17.56 |

## _SMOKER3
<a id="smoker3"></a>

**Computed Smoking Status**

- CalculatedVariables: 8.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 1997
- PDF page: 117
- Description: Four-level smoker status: Everyday smoker, Someday smoker, Former smoker, Non-smoker
- Notes: SMOKE100 = 1 and SMOKEDAY = 1 SMOKE100 = 1 and SMOKEDAY = 2 SMOKE100 = 1 and SMOKEDAY = 3 SMOKE100 = 2 SMOKE100 = 1 and SMOKEDAY = 9 or SMOKE100 = 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Current smoker - now smokes every day | 43,583 | 9.87 | 10.88 |
| 2 | Current smoker - now smokes some days | 17,998 | 4.08 | 4.96 |
| 3 | Former smoker | 122,277 | 27.70 | 23.25 |
| 4 | Never smoked | 239,608 | 54.28 | 55.62 |
| 9 | Don’t know/Refused/Missing | 17,990 | 4.08 | 5.29 |

## _RFSMOK3
<a id="rfsmok3"></a>

**Current Smoking Calculated Variable**

- CalculatedVariables: 8.2 Calculated Variables
- Type: Num
- Column (fixed-width file): 1998
- PDF page: 118
- Description: Adults who are current smokers
- Notes: _SMOKER3 = 3 or 4 _SMOKER3 = 1 or 2 _SMOKER3 = 9

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No | 361,885 | 81.98 | 78.87 |
| 2 | Yes | 61,581 | 13.95 | 15.84 |
| 9 | Don’t know/Refused/Missing | 17,990 | 4.08 | 5.29 |

## DRNKANY5
<a id="drnkany5"></a>

**Drink any alcoholic beverages in past 30 days**

- CalculatedVariables: 9.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 1999
- PDF page: 118
- Description: Adults who reported having had at least one drink of alcohol in the past 30 days.
- Notes: 1 <= ALCDAY5 <= 231 ALCDAY5=888 ALCDAY5=777 ALCDAY5=999, Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 211,346 | 47.87 | 49.23 |
| 2 | No | 208,460 | 47.22 | 44.68 |
| 7 | Don’t know/Not Sure | 3,095 | 0.70 | 0.72 |
| 9 | Refused/Missing | 18,555 | 4.20 | 5.38 |

## DROCDY3_
<a id="drocdy3_"></a>

**Computed drink-occasions-per-day**

- CalculatedVariables: 9.2 Calculated Variables
- Type: Num
- Column (fixed-width file): 2000-2002
- PDF page: 118
- Description: Drink-occasions-per-day
- Notes: ALCDAY5 = 888 ALCDAY5 <= 231 ALCDAY5 = 777 or 999 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | No Drink-Occasions per day | 208,460 | 47.22 | 44.68 |
| 1 - 899 | Drink-Occasions per day | 211,346 | 47.87 | 49.23 |
| 900 | Don’t know/Not Sure Or Refused/Missing | 21,650 | 4.90 | 6.09 |

## _RFBING5
<a id="rfbing5"></a>

**Binge Drinking Calculated Variable**

- CalculatedVariables: 9.3 Calculated Variables
- Type: Num
- Column (fixed-width file): 2003
- PDF page: 119
- Description: Binge drinkers (males having five or more drinks on one occasion, females having four or more drinks on one occasion)
- Notes: ALCDAY5 < 300 and DRNK3GE5 = 0 or ALCDAY5 = 888 ALCDAY5 < 300 and DRNK3GE5 = 1 DRNK3GE5 = 7 or 9 or Missing or ALCDAY5 = 777 or 999 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No | 365,239 | 82.74 | 77.69 |
| 2 | Yes | 50,606 | 11.46 | 15.10 |
| 9 | Don’t know/Refused/Missing | 25,611 | 5.80 | 7.22 |

## _DRNKWEK
<a id="drnkwek"></a>

**Computed number of drinks of alcohol beverages per week**

- CalculatedVariables: 9.4 Calculated Variables
- Type: Num
- Column (fixed-width file): 2004-2008
- PDF page: 119
- Description: Calculated total number of alcoholic beverages consumed per week
- Notes: ALCDAY5 = 888 AVEDRNK2*DROCDY3_*7 ALCDAY5 = 777 or 999 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Did not drink | 208,460 | 47.22 | 44.68 |
| 1 - 98999 | Number of drinks per week | 207,263 | 46.95 | 48.07 |
| 99900 | Don’t know/Not sure/Refused/Missing | 25,733 | 5.83 | 7.25 |

## _RFDRHV5
<a id="rfdrhv5"></a>

**Heavy Alcohol Consumption Calculated Variable**

- CalculatedVariables: 9.5 Calculated Variables
- Type: Num
- Column (fixed-width file): 2009
- PDF page: 119
- Description: Heavy drinkers (adult men having more than 14 drinks per week and adult women having more than 7 drinks per week)
- Notes: SEX = 1 and _DRNKWEK <= 14 or SEX = 2 and _DRNKWEK <= 7 or ALCDAY5 = 888 SEX = 1 and _DRNKWEK > 14 or SEX = 2 and _DRNKWEK > 7 _DRNKWEK = 99900

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | No | 393,658 | 89.17 | 87.39 |
| 2 | Yes | 22,065 | 5.00 | 5.36 |
| 9 | Don’t know/Refused/Missing | 25,733 | 5.83 | 7.25 |

## FTJUDA1_
<a id="ftjuda1_"></a>

**Computed Fruit Juice intake in times per day**

- CalculatedVariables: 10.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 2010-2013
- PDF page: 120
- Description: Fruit juice intake in times per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 9999 | Times per day (two implied decimal places) | 402,921 | 100.00 | 100.00 |
| BLANK | Don’t know/Not Sure Or Refused/Missing | 38,535 |  |  |

## FRUTDA1_
<a id="frutda1_"></a>

**Computed Fruit intake in times per day**

- CalculatedVariables: 10.2 Calculated Variables
- Type: Num
- Column (fixed-width file): 2014-2017
- PDF page: 120
- Description: Fruit intake in times per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 9999 | Times per day (two implied decimal places) | 404,874 | 100.00 | 100.00 |
| BLANK | Don’t know/Not Sure Or Refused/Missing | 36,582 |  |  |

## BEANDAY_
<a id="beanday_"></a>

**Computed Bean intake in times per day**

- CalculatedVariables: 10.3 Calculated Variables
- Type: Num
- Column (fixed-width file): 2018-2021
- PDF page: 120
- Description: Bean intake in times per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 9999 | Times per day (two implied decimal places) | 401,509 | 100.00 | 100.00 |
| BLANK | Don’t know/Not Sure Or Refused/Missing | 39,947 |  |  |

## GRENDAY_
<a id="grenday_"></a>

**Computed Dark Green Vegetable intake in times per day**

- CalculatedVariables: 10.4 Calculated Variables
- Type: Num
- Column (fixed-width file): 2022-2025
- PDF page: 120
- Description: Dark green vegetable intake in times per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 9999 | Times per day (two implied decimal places) | 403,507 | 100.00 | 100.00 |
| BLANK | Don’t know/Not Sure Or Refused/Missing | 37,949 |  |  |

## ORNGDAY_
<a id="orngday_"></a>

**Computed Orange-Colored Vegetable intake in times per day**

- CalculatedVariables: 10.5 Calculated Variables
- Type: Num
- Column (fixed-width file): 2026-2029
- PDF page: 121
- Description: Orange-colored vegetable intake in times per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 9999 | Times per day (two implied decimal places) | 402,198 | 100.00 | 100.00 |
| BLANK | Don’t know/Not Sure Or Refused/Missing | 39,258 |  |  |

## VEGEDA1_
<a id="vegeda1_"></a>

**Computed Other Vegetable intake in times per day**

- CalculatedVariables: 10.6 Calculated Variables
- Type: Num
- Column (fixed-width file): 2030-2033
- PDF page: 121
- Description: Other vegetable intake in times per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 9999 | Times per day (two implied decimal places) | 399,993 | 100.00 | 100.00 |
| BLANK | Don’t know/Not Sure Or Refused/Missing | 41,463 |  |  |

## _MISFRTN
<a id="misfrtn"></a>

**The number of missing fruit responses**

- CalculatedVariables: 10.7 Calculated Variables
- Type: Num
- Column (fixed-width file): 2034
- PDF page: 121
- Description: The number of missing fruit responses

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | No missing fruit responses | 397,745 | 90.10 | 88.41 |
| 1 - 2 | Has 1 or 2 missing fruit responses | 43,711 | 9.90 | 11.59 |

## _MISVEGN
<a id="misvegn"></a>

**The number of missing vegetable responses**

- CalculatedVariables: 10.8 Calculated Variables
- Type: Num
- Column (fixed-width file): 2035
- PDF page: 122
- Description: The number of missing vegetable responses

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | No missing vegetable responses | 390,339 | 88.42 | 86.81 |
| 1 - 4 | Has 1, 2, 3, or 4 missing vegetable responses | 51,117 | 11.58 | 13.19 |

## _FRTRESP
<a id="frtresp"></a>

**Missing any fruit responses**

- CalculatedVariables: 10.9 Calculated Variables
- Type: Num
- Column (fixed-width file): 2036
- PDF page: 122
- Description: Missing any fruit responses

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Not Included - Missing Fruit Responses | 43,711 | 9.90 | 11.59 |
| 1 | Included - Not Missing Fruit Responses | 397,745 | 90.10 | 88.41 |

## _VEGRESP
<a id="vegresp"></a>

**Missing any vegetable responses**

- CalculatedVariables: 10.10 Calculated Variables
- Type: Num
- Column (fixed-width file): 2037
- PDF page: 122
- Description: Missing any vegetable responses

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Not Included - Missing Vegetable Responses | 51,117 | 11.58 | 13.19 |
| 1 | Included - Not Missing Vegetable Responses | 390,339 | 88.42 | 86.81 |

## _FRUTSUM
<a id="frutsum"></a>

**Total fruits consumed per day**

- CalculatedVariables: 10.11 Calculated Variables
- Type: Num
- Column (fixed-width file): 2038-2043
- PDF page: 122
- Description: Total fruits consumed per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 99998 | Number of Fruits consumed per day (two implied decimal places) | 397,745 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 43,711 |  |  |

## _VEGESUM
<a id="vegesum"></a>

**Total vegetables consumed per day**

- CalculatedVariables: 10.12 Calculated Variables
- Type: Num
- Column (fixed-width file): 2044-2049
- PDF page: 123
- Description: Total vegetables consumed per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 99998 | Number of Vegetables consumed per day (two implied decimal places) | 390,339 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 51,117 |  |  |

## _FRTLT1
<a id="frtlt1"></a>

**Consume Fruit 1 or more times per day**

- CalculatedVariables: 10.13 Calculated Variables
- Type: Num
- Column (fixed-width file): 2050
- PDF page: 123
- Description: Consume Fruit 1 or more times per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Consumed fruit one or more times per day | 247,817 | 56.14 | 52.75 |
| 2 | Consumed fruit less than one time per day | 149,928 | 33.96 | 35.66 |
| 9 | Don´t know, refused or missing values | 43,711 | 9.90 | 11.59 |

## _VEGLT1
<a id="veglt1"></a>

**Consume Vegetables 1 or more times per day**

- CalculatedVariables: 10.14 Calculated Variables
- Type: Num
- Column (fixed-width file): 2051
- PDF page: 123
- Description: Consume Vegetables 1 or more times per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Consumed vegetables one or more times per day | 309,561 | 70.12 | 67.63 |
| 2 | Consumed vegetables less than one time per day | 80,778 | 18.30 | 19.18 |
| 9 | Don´t know, refused or missing values | 51,117 | 11.58 | 13.19 |

## _FRT16
<a id="frt16"></a>

**Reported consuming Fruit >16 per day**

- CalculatedVariables: 10.15 Calculated Variables
- Type: Num
- Column (fixed-width file): 2052
- PDF page: 124
- Description: Reported consuming Fruit >16 per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Not Included - Values are too high | 92 | 0.02 | 0.02 |
| 1 | Included - Values are in accepted range | 441,364 | 99.98 | 99.98 |

## _VEG23
<a id="veg23"></a>

**Reported consuming Vegetables >23 per day**

- CalculatedVariables: 10.16 Calculated Variables
- Type: Num
- Column (fixed-width file): 2053
- PDF page: 124
- Description: Reported consuming Vegetables >23 per day

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Not Included - Values are too high | 47 | 0.01 | 0.01 |
| 1 | Included - Values are in accepted range | 441,409 | 99.99 | 99.99 |

## _FRUITEX
<a id="fruitex"></a>

**Fruit Exclusion from analyses**

- CalculatedVariables: 10.17 Calculated Variables
- Type: Num
- Column (fixed-width file): 2054
- PDF page: 124
- Description: Fruit Exclusion from analyses

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | No missing values and in accepted range | 397,653 | 90.08 | 88.39 |
| 1 | Missing Fruit responses | 43,711 | 9.90 | 11.59 |
| 2 | Fruit values out of range | 92 | 0.02 | 0.02 |

## _VEGETEX
<a id="vegetex"></a>

**Vegetable Exclusion from analyses**

- CalculatedVariables: 10.18 Calculated Variables
- Type: Num
- Column (fixed-width file): 2055
- PDF page: 125
- Description: Vegetable Exclusion from analyses

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | No missing values and in accepted range | 390,292 | 88.41 | 86.80 |
| 1 | Missing Vegetable responses | 51,117 | 11.58 | 13.19 |
| 2 | Vegetable values out of range | 47 | 0.01 | 0.01 |

## _TOTINDA
<a id="totinda"></a>

**Leisure Time Physical Activity Calculated Variable**

- CalculatedVariables: 11.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 2058
- PDF page: 125
- Description: Adults who reported doing physical activity or exercise during the past 30 days other than their regular job
- Notes: EXERANY2 = 1 EXERANY2 = 2 EXERANY2 = 7 or 9 or Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Had physical activity or exercise | 296,020 | 67.06 | 65.76 |
| 2 | No physical activity or exercise in last 30 days | 107,444 | 24.34 | 23.26 |
| 9 | Don’t know/Refused/Missing | 37,992 | 8.61 | 10.98 |

## METVL11_
<a id="metvl11_"></a>

**Activity MET Value for First Activity**

- CalculatedVariables: 11.2 Calculated Variables
- Type: Num
- Column (fixed-width file): 2059-2061
- PDF page: 125
- Description: Activity MET Value for First Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Activity MET Value | 14,716 | 5.00 | 6.74 |
| 1 - 128 | Activity MET Value (one implied decimal place) | 279,848 | 95.00 | 93.26 |
| BLANK | Not asked or Missing | 146,892 |  |  |

## METVL21_
<a id="metvl21_"></a>

**Activity MET Value for Second Activity**

- CalculatedVariables: 11.3 Calculated Variables
- Type: Num
- Column (fixed-width file): 2062-2064
- PDF page: 126
- Description: Activity MET Value for Second Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Activity MET Value | 116,805 | 40.33 | 42.58 |
| 1 - 128 | Activity MET Value (one implied decimal place) | 172,809 | 59.67 | 57.42 |
| BLANK | Not asked or Missing | 151,842 |  |  |

## MAXVO2_
<a id="maxvo2_"></a>

**Estimated Age-Gender Specific Maximum Oxygen Consumption**

- CalculatedVariables: 11.4 Calculated Variables
- Type: Num
- Column (fixed-width file): 2065-2069
- PDF page: 126
- Description: Estimated Age-Gender Specific Maximum Oxygen Consumption

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 501 | Estimated Maximum Oxygen Consumption (two implied decimal places) | 436,120 | 98.79 | 98.99 |
| 99900 | Don’t know/Not Sure/Refused/Missing | 5,336 | 1.21 | 1.01 |

## FC60_
<a id="fc60_"></a>

**Estimated Functional Capacity**

- CalculatedVariables: 11.5 Calculated Variables
- Type: Num
- Column (fixed-width file): 2070-2074
- PDF page: 126
- Description: Estimated Functional Capacity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 8590 | Estimated Functional Capacity (2 implied decimal places) | 436,120 | 98.79 | 98.99 |
| 99900 | Don’t know/Not Sure/Refused/Missing | 5,336 | 1.21 | 1.01 |

## ACTIN11_
<a id="actin11_"></a>

**Estimated Activity Intensity for First Activity**

- CalculatedVariables: 11.6 Calculated Variables
- Type: Num
- Column (fixed-width file): 2075
- PDF page: 127
- Description: Estimated Activity Intensity for First Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Not Moderate or Vigorous or No Activity | 14,662 | 5.03 | 6.77 |
| 1 | Moderate | 180,152 | 61.82 | 69.12 |
| 2 | Vigorous | 96,620 | 33.15 | 24.11 |
| BLANK | Not asked or Missing | 150,022 |  |  |

## ACTIN21_
<a id="actin21_"></a>

**Estimated Activity Intensity for Second Activity**

- CalculatedVariables: 11.7 Calculated Variables
- Type: Num
- Column (fixed-width file): 2076
- PDF page: 127
- Description: Estimated Activity Intensity for Second Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Not Moderate or Vigorous or No Activity | 115,676 | 40.36 | 42.58 |
| 1 | Moderate | 91,540 | 31.94 | 36.78 |
| 2 | Vigorous | 79,368 | 27.69 | 20.64 |
| BLANK | Not asked or Missing | 154,872 |  |  |

## PADUR1_
<a id="padur1_"></a>

**Minutes of First Activity**

- CalculatedVariables: 11.8 Calculated Variables
- Type: Num
- Column (fixed-width file): 2077-2079
- PDF page: 127
- Description: Minutes of First Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 599 | Minutes of Activity | 287,716 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 153,740 |  |  |

## PADUR2_
<a id="padur2_"></a>

**Minutes of Second Activity**

- CalculatedVariables: 11.9 Calculated Variables
- Type: Num
- Column (fixed-width file): 2080-2082
- PDF page: 128
- Description: Minutes of Second Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 599 | Minutes of Activity | 192,327 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 249,129 |  |  |

## PAFREQ1_
<a id="pafreq1_"></a>

**Physical Activity Frequency per Week for First Activity**

- CalculatedVariables: 11.10 Calculated Variables
- Type: Num
- Column (fixed-width file): 2083-2087
- PDF page: 128
- Description: Physical Activity Frequency per Week for First Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 98999 | Activity times per week (3 implied decimal places) | 291,147 | 99.99 | 99.99 |
| 99000 | Don’t know/Not Sure/Refused | 18 | 0.01 | 0.01 |
| BLANK | Not asked or Missing | 150,291 |  |  |

## PAFREQ2_
<a id="pafreq2_"></a>

**Physical Activity Frequency per Week for Second Activity**

- CalculatedVariables: 11.11 Calculated Variables
- Type: Num
- Column (fixed-width file): 2088-2092
- PDF page: 128
- Description: Physical Activity Frequency per Week for Second Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 98999 | Activity times per week (3 implied decimal places) | 194,674 | 99.99 | 99.99 |
| 99000 | Don’t know/Not Sure/Refused | 22 | 0.01 | 0.01 |
| BLANK | Not asked or Missing | 246,760 |  |  |

## _MINAC11
<a id="minac11"></a>

**Minutes of Physical Activity per week for First Activity**

- CalculatedVariables: 11.12 Calculated Variables
- Type: Num
- Column (fixed-width file): 2093-2097
- PDF page: 129
- Description: Minutes of Physical Activity per week for First Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Minutes of Activity per week | 18,305 | 6.40 | 8.30 |
| 1 - 99999 | Minutes of Activity per week | 267,612 | 93.60 | 91.70 |
| BLANK | Not asked or Missing | 155,539 |  |  |

## _MINAC21
<a id="minac21"></a>

**Minutes of Physical Activity per week for Second Activity**

- CalculatedVariables: 11.13 Calculated Variables
- Type: Num
- Column (fixed-width file): 2098-2102
- PDF page: 129
- Description: Minutes of Physical Activity per week for Second Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Minutes of Activity per week | 120,708 | 42.55 | 44.76 |
| 1 - 99999 | Minutes of Activity per week | 162,946 | 57.45 | 55.24 |
| BLANK | Not asked or Missing | 157,802 |  |  |

## STRFREQ_
<a id="strfreq_"></a>

**Strength Activity Frequency per Week**

- CalculatedVariables: 11.14 Calculated Variables
- Type: Num
- Column (fixed-width file): 2103-2107
- PDF page: 129
- Description: Strength Activity Frequency per Week

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 98999 | Strength Activity times per week (3 implied decimal places) | 397,424 | 100.00 | 100.00 |
| 99000 | Don’t know/Not Sure/Refused | 19 | 0.00 | 0.00 |
| BLANK | Not asked or Missing | 44,013 |  |  |

## PAMISS1_
<a id="pamiss1_"></a>

**Missing Physical Activity Data**

- CalculatedVariables: 11.15 Calculated Variables
- Type: Num
- Column (fixed-width file): 2108
- PDF page: 130
- Description: Missing Physical Activity Data

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 | Not Missing Physical Activity Data | 382,125 | 86.56 | 84.88 |
| 1 | Missing Physical Activity Data | 21,339 | 4.83 | 4.14 |
| 9 | Don’t know/Not Sure/Refused | 37,992 | 8.61 | 10.98 |

## PAMIN11_
<a id="pamin11_"></a>

**Minutes of Physical Activity per week for First Activity**

- CalculatedVariables: 11.16 Calculated Variables
- Type: Num
- Column (fixed-width file): 2109-2113
- PDF page: 130
- Description: Minutes of Physical Activity per week for First Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 99999 | Minutes of Activity per week | 282,976 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 158,480 |  |  |

## PAMIN21_
<a id="pamin21_"></a>

**Minutes of Physical Activity per week for Second Activity**

- CalculatedVariables: 11.17 Calculated Variables
- Type: Num
- Column (fixed-width file): 2114-2118
- PDF page: 130
- Description: Minutes of Physical Activity per week for Second Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 99999 | Minutes of Activity per week | 280,742 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 160,714 |  |  |

## PA1MIN_
<a id="pa1min_"></a>

**Minutes of total Physical Activity per week**

- CalculatedVariables: 11.18 Calculated Variables
- Type: Num
- Column (fixed-width file): 2119-2123
- PDF page: 131
- Description: Minutes of total Physical Activity per week

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 99999 | Minutes of Activity per week | 289,037 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 152,419 |  |  |

## PAVIG11_
<a id="pavig11_"></a>

**Minutes of Vigorous Physical Activity per week for First Activity**

- CalculatedVariables: 11.19 Calculated Variables
- Type: Num
- Column (fixed-width file): 2124-2128
- PDF page: 131
- Description: Minutes of Vigorous Physical Activity per week for First Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 99999 | Minutes of Activity per week | 287,778 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 153,678 |  |  |

## PAVIG21_
<a id="pavig21_"></a>

**Minutes of Vigorous Physical Activity per week for Second Activity**

- CalculatedVariables: 11.20 Calculated Variables
- Type: Num
- Column (fixed-width file): 2129-2133
- PDF page: 131
- Description: Minutes of Vigorous Physical Activity per week for Second Activity

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 99999 | Minutes of Activity per week | 283,415 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 158,041 |  |  |

## PA1VIGM_
<a id="pa1vigm_"></a>

**Minutes of total Vigorous Physical Activity per week**

- CalculatedVariables: 11.21 Calculated Variables
- Type: Num
- Column (fixed-width file): 2134-2138
- PDF page: 131
- Description: Minutes of total Vigorous Physical Activity per week

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 0 - 99999 | Minutes of Activity per week | 290,486 | 100.00 | 100.00 |
| BLANK | Not asked or Missing | 150,970 |  |  |

## _PACAT1
<a id="pacat1"></a>

**Physical Activity Categories**

- CalculatedVariables: 11.22 Calculated Variables
- Type: Num
- Column (fixed-width file): 2139
- PDF page: 132
- Description: Physical Activity Categories

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Highly Active | 131,374 | 29.76 | 26.63 |
| 2 | Active | 71,004 | 16.08 | 16.49 |
| 3 | Insufficiently Active | 71,142 | 16.12 | 17.79 |
| 4 | Inactive | 112,041 | 25.38 | 24.61 |
| 9 | Don’t know/Not Sure/Refused/Missing | 55,895 | 12.66 | 14.48 |

## _PAINDX1
<a id="paindx1"></a>

**Physical Activity Index**

- CalculatedVariables: 11.23 Calculated Variables
- Type: Num
- Column (fixed-width file): 2140
- PDF page: 132
- Description: Physical Activity Index

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Meet Aerobic Recommendations | 205,013 | 46.44 | 43.59 |
| 2 | Did Not Meet Aerobic Recommendations | 183,183 | 41.50 | 42.40 |
| 9 | Don’t know/Not Sure/Refused/Missing | 53,260 | 12.06 | 14.01 |

## _PA150R2
<a id="pa150r2"></a>

**150 Minute Physical Activity Calculated Variable**

- CalculatedVariables: 11.24 Calculated Variables
- Type: Num
- Column (fixed-width file): 2141
- PDF page: 132
- Description: Adults that participated in 150 minutes (or vigorous equivalent minutes) of physical activity per week.

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | 150+ minutes (or vigorous equivalent minutes) of physical activity | 205,013 | 46.44 | 43.59 |
| 2 | 1-149 minutes (or vigorous equivalent minutes) of physical activity | 71,142 | 16.12 | 17.79 |
| 3 | 0 minutes (or vigorous equivalent minutes) of physical activity | 112,041 | 25.38 | 24.61 |
| 9 | Don’t know/Not Sure/Refused/Missing | 53,260 | 12.06 | 14.01 |

## _PA300R2
<a id="pa300r2"></a>

**300 Minute Physical Activity Calculated Variable**

- CalculatedVariables: 11.25 Calculated Variables
- Type: Num
- Column (fixed-width file): 2142
- PDF page: 133
- Description: Adults that participated in 300 minutes (or vigorous equivalent minutes) of physical activity per week.

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | 301+ minutes (or vigorous equivalent minutes) of physical activity | 131,374 | 29.76 | 26.63 |
| 2 | 1-300 minutes (or vigorous equivalent minutes) of physical activity | 142,146 | 32.20 | 34.28 |
| 3 | 0 minutes (or vigorous equivalent minutes) of physical activity | 112,041 | 25.38 | 24.61 |
| 9 | Don’t know/Not Sure/Refused/Missing | 55,895 | 12.66 | 14.48 |

## _PA30021
<a id="pa30021"></a>

**300 Minute Physical Activity 2-Level Calculated Variable**

- CalculatedVariables: 11.26 Calculated Variables
- Type: Num
- Column (fixed-width file): 2143
- PDF page: 133
- Description: Adults that participated in 300 minutes (or vigorous equivalent minutes) of physical activity per week (2-levels).

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | 301+ minutes (or vigorous equivalent minutes) of physical activity | 131,374 | 29.76 | 26.63 |
| 2 | 0-300 minutes (or vigorous equivalent minutes) of physical activity | 254,187 | 57.58 | 58.89 |
| 9 | Don’t know/Not Sure/Refused/Missing | 55,895 | 12.66 | 14.48 |

## _PASTRNG
<a id="pastrng"></a>

**Muscle Strengthening Recommendation**

- CalculatedVariables: 11.27 Calculated Variables
- Type: Num
- Column (fixed-width file): 2144
- PDF page: 133
- Description: Muscle Strengthening Recommendation

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Meet muscle strengthening recommendations | 109,624 | 24.83 | 26.42 |
| 2 | Did not meet muscle strengthening recommendations | 287,819 | 65.20 | 61.12 |
| 9 | Don’t know/Not Sure/Refused/Missing | 44,013 | 9.97 | 12.46 |

## _PAREC1
<a id="parec1"></a>

**Aerobic and Strengthening Guideline**

- CalculatedVariables: 11.28 Calculated Variables
- Type: Num
- Column (fixed-width file): 2145
- PDF page: 134
- Description: Aerobic and Strengthening Guideline

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Met Both Guidelines | 74,696 | 16.92 | 17.29 |
| 2 | Met Aerobic Guidelines Only | 127,716 | 28.93 | 25.70 |
| 3 | Met Strengthening Guidelines Only | 31,347 | 7.10 | 8.38 |
| 4 | Did not meet Either Guideline | 150,188 | 34.02 | 33.62 |
| 9 | Don’t know/Not Sure/Refused/Missing | 57,509 | 13.03 | 15.01 |

## _PASTAE1
<a id="pastae1"></a>

**Aerobic and Strengthening (2-level)**

- CalculatedVariables: 11.29 Calculated Variables
- Type: Num
- Column (fixed-width file): 2146
- PDF page: 134
- Description: Aerobic and Strengthening (2-level)

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Met Both Guidelines | 74,696 | 16.92 | 17.29 |
| 2 | Did Not Meet Both Guidelines | 309,251 | 70.05 | 67.70 |
| 9 | Don’t know/Not Sure/Refused/Missing | 57,509 | 13.03 | 15.01 |

## _LMTACT1
<a id="lmtact1"></a>

**Limited usual activities**

- CalculatedVariables: 12.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 2147
- PDF page: 134
- Description: Limited usual activities

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Told have arthritis and have limited usual activities | 67,129 | 15.30 | 11.08 |
| 2 | Told have arthritis and no limited usual activities | 67,911 | 15.48 | 11.02 |
| 3 | Not told they have arthritis | 290,621 | 66.25 | 75.32 |
| 9 | Don´t know, refused or missing usual activities limited | 12,996 | 2.96 | 2.58 |
| BLANK | Don´t know, refused or missing arthritis or not asked | 2,799 |  |  |

## _LMTWRK1
<a id="lmtwrk1"></a>

**Limited work activities**

- CalculatedVariables: 12.2 Calculated Variables
- Type: Num
- Column (fixed-width file): 2148
- PDF page: 135
- Description: Limited work activities

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Told have arthritis and have limited work | 42,362 | 9.66 | 7.72 |
| 2 | Told have arthritis and no limited work | 90,058 | 20.53 | 14.03 |
| 3 | Not told they have arthritis | 290,621 | 66.25 | 75.32 |
| 9 | Don´t know, refused or missing work limited | 15,616 | 3.56 | 2.93 |
| BLANK | Don´t know, refused or missing arthritis or not asked | 2,799 |  |  |

## _LMTSCL1
<a id="lmtscl1"></a>

**Limited social activities**

- CalculatedVariables: 12.3 Calculated Variables
- Type: Num
- Column (fixed-width file): 2149
- PDF page: 135
- Description: Limited social activities

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Told have arthritis and social activities limited a lot | 24,937 | 5.68 | 4.45 |
| 2 | Told have arthritis and social activities limited a little | 32,422 | 7.39 | 5.57 |
| 3 | Told have arthritis and social activities not limited | 77,678 | 17.71 | 12.05 |
| 4 | Not told they have arthritis | 290,621 | 66.25 | 75.32 |
| 9 | Don´t know, refused or missing social activities limited | 12,999 | 2.96 | 2.61 |
| BLANK | Don´t know, refused or missing arthritis or not asked | 2,799 |  |  |

## _RFSEAT2
<a id="rfseat2"></a>

**Always or Nearly Always Wear Seat Belts**

- CalculatedVariables: 13.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 2150
- PDF page: 135
- Description: Always or Nearly Always Wear Seat Belts Calculated Variable

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Always or Almost Always Wear Seat Belt | 376,993 | 85.40 | 82.76 |
| 2 | Sometimes, Seldom, or Never Wear Seat Belt | 21,667 | 4.91 | 4.96 |
| 9 | Don’t know/Not Sure Or Refused/Missing | 42,796 | 9.69 | 12.27 |

## _RFSEAT3
<a id="rfseat3"></a>

**Always Wear Seat Belts**

- CalculatedVariables: 13.2 Calculated Variables
- Type: Num
- Column (fixed-width file): 2151
- PDF page: 136
- Description: Always Wear Seat Belts Calculated Variable

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Always Wear Seat Belt | 349,444 | 79.16 | 77.34 |
| 2 | Don’t Always Wear Seat Belt | 49,216 | 11.15 | 10.38 |
| 9 | Don’t know/Not Sure Or Refused/Missing | 42,796 | 9.69 | 12.27 |

## _FLSHOT6
<a id="flshot6"></a>

**Flu Shot Calculated Variable**

- CalculatedVariables: 14.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 2152
- PDF page: 136
- Description: Adults aged 65+ who have had a flu shot within the past year
- Notes: AGE >=65 and FLUSHOT6 = 1 AGE >=65 and FLUSHOT6 = 2

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 86,683 | 54.88 | 51.43 |
| 2 | No | 52,328 | 33.13 | 33.52 |
| 9 | Don’t know/Not Sure Or Refused/Missing | 18,943 | 11.99 | 15.05 |
| BLANK | Age Less Than 65 | 283,502 |  |  |

## _PNEUMO2
<a id="pneumo2"></a>

**Pneumonia Vaccination Calculated Variable**

- CalculatedVariables: 14.2 Calculated Variables
- Type: Num
- Column (fixed-width file): 2153
- PDF page: 136
- Description: Adults aged 65+ who have ever had a pneumonia vaccination
- Notes: AGE >= 65 and PNEUVAC3 = 1 AGE >= 65 and PNEUVAC3 = 2 AGE = 7 or 9 or Missing or PNEUVAC3 = 7 or 9 or Missing AGE < 65

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 98,752 | 62.52 | 58.59 |
| 2 | No | 35,792 | 22.66 | 23.54 |
| 9 | Don’t know/Not Sure Or Refused/Missing | 23,410 | 14.82 | 17.87 |
| BLANK | Age Less Than 65 | 283,502 |  |  |

## _AIDTST3
<a id="aidtst3"></a>

**Ever been tested for HIV calculated variable**

- CalculatedVariables: 15.1 Calculated Variables
- Type: Num
- Column (fixed-width file): 2154
- PDF page: 137
- Description: Adults who have ever been tested for HIV
- Notes: HIVTST6 = 1 HIVTST6 = 2 HIVTST6 = 7 or 9 HIVTST6 = Missing

| Value | Value Label | Frequency | Percentage | Weighted % |
|---|---|--:|--:|--:|
| 1 | Yes | 113,779 | 28.58 | 36.10 |
| 2 | No | 269,733 | 67.76 | 58.97 |
| 9 | Don’t know/Not Sure/Refused | 14,557 | 3.66 | 4.93 |
| BLANK | Not asked or missing | 43,387 |  |  |
