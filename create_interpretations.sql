-- Step 1: get list of samples
with samples as (
  select distinct trim(Sample_Id) as Sample_Id from `Massarray_POC.Rawdata`
)
-- check result of subquery above
   -- select * from samples


-- Step 2: Check subrules
,subrule as (
  select
    s.Sample_Id, -- samples
    rd.Assay_Id, if(rd.Assay_Id is not null and rd.Call is null, "blank", rd.Call) as Call, -- rawdata
    rl.Rule_ID,	rl.Gene, rl.Primer, rl.Call as RuleCall, rl.Final_interpretation, -- subrules
    if(if(Assay_Id is not null and rd.Call is null, "blank", rd.Call) = rl.Call, 1, 0) as IsPassedSubRule -- 1 if subrule passed, 0 if it did not
  from
    samples as s -- samples
  cross join
    `cidmicroseq.Massarray_POC.RulesLong` as rl -- creates tables with one row per sample and subrules
  left join
    `Massarray_POC.Rawdata` as rd -- joins rawdata column by sample and primer
  on
    trim(rl.Primer) = trim(rd.Assay_Id) and -- trim gets rid of
    trim(s.Sample_Id) = trim(rd.Sample_Id)
)
-- check result of subquery above:
   -- select * from subrule where Sample_Id = "BRA001"
   -- and Gene = "aac(3)-II"
   -- and Rule_Id = 22
   -- order by Gene, Rule_Id


--Step 3: Checks if rules pass by checking all subrules for each strain and Rule_Id
, checkedrules as (
  select
    *,
    min(IsPassedSubRule) over (partition by Sample_Id, Rule_Id) as IsPassedRule -- If all IsPassedSubRule in a record groups with the same Sample_Id and Rule_Id is 1 the the rule is passed --> 1, otherwise --> 0
  from
    subrule
)
-- check result of subquery above
  -- select * from checkedrules where Sample_Id = "BRA001"
  -- and Gene = "aac(3)-II"
  -- and Rule_Id = 22
  -- order by Gene, Rule_Id


-- Step 4: Group records to have just one record per strain, gene and rule. We don't want a record per subrule
,interpretations as(
  select
    Sample_Id,
    Rule_Id,
    Gene,
    Final_interpretation,
    IsPassedRule
  from
    checkedrules
  group by
    Sample_Id,
    Rule_Id,
    Gene,
    Final_interpretation,
    IsPassedRule
)
-- check result of subquery above:
   -- select * from interpretations where Sample_Id = "BRA001"
  -- and Gene = "aac(3)-II"
   -- and Rule_Id = 22
   -- order by Gene

-- Step 5: Create a table that has one row per strain and gene with interpretations if any passed
select
  sg.Sample_Id,
  sg.Gene,
  i.* except(Sample_Id, Gene)
from
  (select distinct trim(Sample_Id) as Sample_Id, trim(Gene) as Gene from interpretations) as sg -- creates aw table with one record per strain and gene
left join
  interpretations as i -- joins the interpretations where the rules passed. Null values are given if the strain gene matches no rule
  on
    sg.Sample_Id = i.Sample_Id and
    sg.Gene = trim(i.Gene) and
    i.IsPassedRule = 1
 --where sg.Sample_Id = "BRA001"
    --and sg.Gene = "aac(3)-II"
order by
  Sample_Id, Gene, Rule_Id
