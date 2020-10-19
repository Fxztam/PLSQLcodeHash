CREATE OR REPLACE FUNCTION get_CodeHash4Cmp (p_cname VARCHAR2, p_result VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 AS
  /*
     Friedhold Matz : Created  - 2020-10-18
                      Modified - 
  */
  l_inp         CLOB := empty_clob();
  l_res         CLOB := empty_clob();
  l_len         NUMBER(6);
  l_offset      NUMBER(6);
  l_char1       VARCHAR(1);
  l_char2       VARCHAR(1);  
  C_SPACE       CONSTANT VARCHAR2(1) := ' ';
  C_TAB         CONSTANT VARCHAR2(1) := chr(09);
  C_CRETURN     CONSTANT VARCHAR2(1) := chr(10);
  C_SLCOMM      CONSTANT VARCHAR2(1) := '-';
  C_MLCOMM1     CONSTANT VARCHAR2(1) := '/';
  C_MLCOMM2     CONSTANT VARCHAR2(1) := '*';
  l_hash        RAW(64):= NULL;

BEGIN
  -- get source from p_cname in l_clob 
  FOR rec IN (select text from all_source where name = p_cname) LOOP
      l_inp:= l_inp || rec.text;
  END LOOP;
  l_len := dbms_lob.getlength(l_inp);

  IF l_len=0 THEN
     RETURN '$$$ "'||p_cname||'" : NOT FOUND $$$';
  END IF;

  l_offset := 1;
   
  -- Read till the current offset is less the length of inp_clob
  <<normal_state>>
  WHILE(l_offset <= l_len) LOOP
      l_char1 := lower(Substr(l_inp, l_offset, 1));
      l_offset:= l_offset+1;
      CASE l_char1 
         WHEN C_SPACE   THEN GOTO space_state;
         WHEN C_TAB     THEN GOTO tab_state;
         WHEN C_CRETURN THEN GOTO creturn_state;
         WHEN C_SLCOMM  THEN 
              -- look ahead
              l_char2 := Substr(l_inp, l_offset, 1);
              IF l_char2=C_SLCOMM THEN l_offset:=l_offset+1; GOTO slcomment_state; END IF;
         WHEN C_MLCOMM1 THEN 
              -- look ahead
              l_char2 := Substr(l_inp, l_offset, 1);
              IF l_char2=C_MLCOMM2 THEN l_offset:=l_offset+1; GOTO mlcomment_state; END IF;
         ELSE NULL;
      END CASE;
      l_res := l_res || l_char1;
  END LOOP;
  GOTO fine;
  
  -- BO `go over` states --
  <<space_state>>
  WHILE(l_offset <= l_len) LOOP  
      l_char1 := Substr(l_inp, l_offset, 1);
      IF l_char1<>C_SPACE THEN GOTO normal_state; END IF;     
      l_offset:= l_offset+1;
  END LOOP;
  GOTO fine;

  <<tab_state>>
  WHILE(l_offset <= l_len) LOOP  
      l_char1 := Substr(l_inp, l_offset, 1);
      IF l_char1<>C_TAB THEN GOTO normal_state; END IF;     
      l_offset:= l_offset+1;
  END LOOP;
  GOTO fine;
  
  <<creturn_state>>
  WHILE(l_offset <= l_len) LOOP 
      l_char1 := Substr(l_inp, l_offset, 1);           
      IF l_char1<>C_CRETURN THEN GOTO normal_state; END IF; 
      l_offset:= l_offset+1;    
  END LOOP;
  GOTO fine;

  <<slcomment_state>>
  WHILE(l_offset <= l_len) LOOP  
      l_char1 := Substr(l_inp, l_offset, 1);
      l_offset:= l_offset+1;
      IF l_char1=C_CRETURN THEN GOTO normal_state; END IF;     
  END LOOP;
  GOTO fine;

  <<mlcomment_state>>
  WHILE(l_offset <= l_len) LOOP  
      l_char1 := Substr(l_inp, l_offset, 1);
      l_offset:= l_offset+1;
      IF l_char1=C_MLCOMM2 THEN 
         -- look ahead
         l_char2 := Substr(l_inp, l_offset, 1);
         IF l_char2=C_MLCOMM1 THEN l_offset:=l_offset+1; GOTO normal_state; END IF; 
      END IF;     
  END LOOP;
  GOTO fine;
  -- EO `go over` states --
  
  <<fine>>

  l_hash := Sys.Dbms_Crypto.Hash(Utl_Raw.CAST_TO_RAW(l_res), 5); -- SHA384 --

  IF p_result IS NOT NULL THEN
     IF l_hash = p_result THEN
        RETURN p_cname||' : OK';
     ELSE
        RETURN p_cname||' : ERROR';
     END IF;
     ELSE
        RETURN l_hash;
  END IF; 
  
END get_CodeHash4Cmp;
