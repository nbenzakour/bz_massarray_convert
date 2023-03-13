SELECT
  *
FROM
  (
  SELECT
    Rule_ID,
    Gene,
    Primer_1 as Primer,
    Call_1 as Call,
    Final_interpretation
  FROM
    `cidmicroseq.Massarray_POC.Rules`

  union all

  SELECT
    Rule_ID,
    Gene,
    Primer_2 as Primer,
    Call_2 as Call,
    Final_interpretation
  FROM
    `cidmicroseq.Massarray_POC.Rules`

  union all

  SELECT
    Rule_ID,
    Gene,
    Primer_3 as Primer,
    Call_3 as Call,
    Final_interpretation
  FROM
    `cidmicroseq.Massarray_POC.Rules`

  union all

  SELECT
    Rule_ID,
    Gene,
    Primer_4 as Primer,
    Call_4 as Call,
    Final_interpretation
  FROM
    `cidmicroseq.Massarray_POC.Rules`

  union all

  SELECT
    Rule_ID,
    Gene,
    Primer_5 as Primer,
    Call_5 as Call,
    Final_interpretation
  FROM
    `cidmicroseq.Massarray_POC.Rules`

  union all

  SELECT
    Rule_ID,
    Gene,
    Primer_6 as Primer,
    Call_6 as Call,
    Final_interpretation
  FROM
    `cidmicroseq.Massarray_POC.Rules`
)
where
  Primer is not null
