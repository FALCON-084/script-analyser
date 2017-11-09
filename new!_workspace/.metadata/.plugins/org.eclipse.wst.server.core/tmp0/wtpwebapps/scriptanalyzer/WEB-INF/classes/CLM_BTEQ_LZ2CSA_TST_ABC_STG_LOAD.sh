 exec 1> $CODE/edlr2/logs/CLM_BTEQ_LZ2CSA_TST_ABC_STG_LOAD_$(date +"%Y%m%d_%H%M%S").log 2>&1



#===============================================================================
# TITLE             :CLM_BTEQ_LZ2CSA_TST_ABC_STG_LOAD
# Filename          :CLM_BTEQ_LZ2CSA_TST_ABC_STG_LOAD.sh
# Description       :This script is invoked to load data from LZ tables to TST_ABC_STG TABLE 
# SOURCE Tables     :LZ_TEMP_TST_CLM_GNCCLMP,LZ_TEMP_TST_CLM_GNCCLMP,LZ_TEMP_TST_CLM_GNCHSPP,LZ_CODES_CONV,LZ_LOAD_LOG,CSA_LOAD_LOG
# TARGET Tables     :TST_ABC_STG 
# KEY COLUMNS       :CLM_ADJSTMNT_KEY,CLM_LINE_NBR
# Developer         :COGNIZANT
# Created ON        :12/11/2008
# Location          :COGNIZANT,KOLKATA
# Logic             :Populate all the latest records with appropriate transformations from LZ_TEMP_TST_CLM_GNCCLMP
#                    ,LS_WGS_GNCDTLP,LZ_CODES_CONV and WLP_CNVRT_LOB_STG tables based on the parameters SOR_CD,SUBJ_AREA_NM
#                    ,WORK_FLOW_NM,WP_OLD_LOB into the TST_ABC_STG table based on the join of the source tables
#                    on the basis of LOAD_LOG_KEY from the LZ_LOAD_LOG AND CSA_LOAD_LOG tables.
# Parameters        :Database name, Logon directory, Logon ID,SOR_CD,SUBJ_AREA_NM,WORK_FLOW_NM
#===============================================================================

      echo "script file="$0
      PARM_FILE=$1
      echo "parm file="$PARM_FILE.parm

. $CODE/edlr2/scripts/$PARM_FILE.parm

#===============================================================================
#BTEQ Script
#=============================================================================== 
bteq <<EOF

.SET WIDTH 150;

/********************************************************************************
Put BTEQ in Transaction mode
********************************************************************************/

.SET SESSION TRANSACTION BTET;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/**************************************************************************************************
Parms are set in the WGS_PARM.parm file in the .sh file that calls this .ctl file.
--Extract username and password and logon to database.
**************************************************************************************************/

.run file $LOGON/$LOGON_ID;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/
SELECT SESSION;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

SET QUERY_BAND = 'ApplicationName=$0;Frequency=Daily;' FOR SESSION;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/**************************************************************************************************
Set default database based on parameter in parm file if needs to be different than the logon ID's 
default database.
--Set default database derived from parameter file
**************************************************************************************************/

DATABASE $ETL_VIEWS_DB;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/**************************************************************************************************
DELETE SCRIPT FOR TST_ABC_STG IN CASE OF RELOADING       
/*************************************************************************************************/



DELETE  FROM TST_ABC_STG WHERE LOAD_LOG_KEY=(SELECT CSA_LOAD_LOG_KEY FROM LZ_TEMP_TST_CLM_GNCCLMP GROUP BY 1);

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/
DELETE  FROM COA_CUST_LOB_STG WHERE LOAD_LOG_KEY=(SELECT CSA_LOAD_LOG_KEY FROM LZ_TEMP_TST_CLM_GNCCLMP GROUP BY 1);

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

DELETE FROM AUDT_STTSTC where 
LOAD_LOG_KEY=(SELECT CSA_LOAD_LOG_KEY FROM LZ_TEMP_TST_CLM_GNCCLMP GROUP BY 1)
AND AUDT_RULE_ID=916 ;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/


/*********************************** HIX OCT Release********************************/

/***************************************************************************************************
Insert into LZ_TEMP_TST_CLM_NATP_EA1_CF_CHK table
****************************************************************************************************/

DELETE FROM LZ_TEMP_TST_CLM_NATP_EA1_CF_CHK ALL;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/

INSERT INTO LZ_TEMP_TST_CLM_NATP_EA1_CF_CHK
      (
      DDC_EXT_DCN_CC ,
      DDC_EXT_DCN_NO ,
      DDC_EXT_SEQ_NBR,
      DDC_EXT_DCN_ITM_CD,
      OLD_LOB,
      DDC_NAT_EA1_EXCHANGE_IND,
      DDC_NAT_EA1_CONT_METAL_LVL,
      DDC_NAT_EA1_CERTFN_IND,
      DDC_NAT_EA1_COMPANY_CHARTFLD ,
      DDC_NAT_EA1_MBU_CHARTFLD ,
      DDC_NAT_EA1_FUND_TYPE_CHARTFLD ,
      DDC_NAT_EA1_PRODUCT_CHARTFLD ,
      LOAD_LOG_KEY
      )
      SELECT 
      
                      /**************DDC_EXT_DCN_CC*************/
                      CLMP.DDC_EXT_DCN_CC AS DDC_EXT_DCN_CC,
                      
                      /*************DDC_EXT_DCN_NO*********************/
                      CLMP.DDC_EXT_DCN_NO AS DDC_EXT_DCN_NO,
                      
                      /*********************DDC_EXT_SEQ_NBR*********************/
                      CLMP.DDC_EXT_SEQ_NUMBER AS DDC_EXT_SEQ_NBR,
                      
                      /*****************************DDC_EXT_DCN_ITM_CD***************************/
                      CLMP.DDC_EXT_DCN_ITM_CDE AS DDC_EXT_DCN_ITM_CD,
                      
                     /********************************OLD_LOB*********************************/
                     CLMP.OLD_LOB AS OLD_LOB,
                    
                    /********************************DDC_NAT_EA1_EXCHANGE_IND**********************************/
                               CASE WHEN  
                                    NATP1.DDC_NAT_EA1_EXCHANGE_IND IS NULL OR NATP1.DDC_NAT_EA1_EXCHANGE_IND=''
                               THEN ' '
                               ELSE NATP1.DDC_NAT_EA1_EXCHANGE_IND 
                               END AS DDC_NAT_EA1_EXCHANGE_IND,
                                                
                    /********************************DDC_NAT_EA1_CONT_METAL_LVL**********************************/
                                CASE WHEN 
                                    NATP1.DDC_NAT_EA1_CONT_METAL_LVL IS NULL OR NATP1.DDC_NAT_EA1_CONT_METAL_LVL =''
                                THEN ' '
                                 ELSE NATP1.DDC_NAT_EA1_CONT_METAL_LVL  
                                 END AS DDC_NAT_EA1_CONT_METAL_LVL,
                                                
                    /********************************DDC_NAT_EA1_CERTFN_IND**********************************/
                                CASE WHEN  
                                    NATP1.DDC_NAT_EA1_CERTFN_IND IS NULL OR NATP1.DDC_NAT_EA1_CERTFN_IND=''
                                THEN ' '
                                ELSE NATP1.DDC_NAT_EA1_CERTFN_IND 
                                END AS DDC_NAT_EA1_CERTFN_IND,
                                                 
                /************************** DDC_NAT_EA1_COMPANY_CHARTFLD*******************/                         
                NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD AS DDC_NAT_EA1_COMPANY_CHARTFLD,
                
                /**************************DDC_NAT_EA1_MBU_CHARTFLD***************************/
                NATP1.DDC_NAT_EA1_MBU_CHARTFLD AS DDC_NAT_EA1_MBU_CHARTFLD,
                
                /**********************DDC_NAT_EA1_FUND_TYPE_CHARTFLD**************************/
                NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD AS DDC_NAT_EA1_FUND_TYPE_CHARTFLD,
                
                /***********************DDC_NAT_EA1_PRODUCT_CHARTFLD*********************************/
                NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD AS DDC_NAT_EA1_PRODUCT_CHARTFLD,
                
                /***********************************************LOAD_LOG_KEY****************************/
                CLMP.LOAD_LOG_KEY AS LOAD_LOG_KEY
                            
                            FROM LZ_TEMP_TST_CLM_GNCCLMP CLMP
                                  
                                  LEFT OUTER JOIN LZ_WGS_GNCNATP_EA1 NATP1
                                  ON CLMP.DDC_EXT_DCN_CC=NATP1.DDC_EXT_DCN_CC
          AND CLMP.DDC_EXT_DCN_NO=NATP1.DDC_EXT_DCN_NO
          AND CLMP.DDC_EXT_SEQ_NUMBER=NATP1.DDC_EXT_SEQ_NBR
          AND CLMP.DDC_EXT_DCN_ITM_CDE=NATP1.DDC_EXT_DCN_ITM_CD
          AND CLMP.LOAD_LOG_KEY=NATP1.LOAD_LOG_KEY
            
                                  GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
                                                                                                
        ;
/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/

call $DB_RFRSH_STAT_PROC.REFRESH_STTSTCS_TBL('$ETL_TEMP_DB','LZ_TEMP_TST_CLM_NATP_EA1_CF_CHK','N',RTRN_CD,RTRN_CNT,MSG);

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/********************************************* HIX OCT RELEASE END *****************************************************/


/**************************************************************************************************
These are the steps required to load the TST_ABC_STG table from LZ_TEMP_TST_CLM_GNCCLMP
,WLP_CNVRT_LOB_STG LKP,LZ_LOAD_LOG and CSA_LOAD_LOG tables in the Landing Zone.               
/*************************************************************************************************/

/**************************************************************************************************
STEP 1 :INSERT DATA INTO THE CSA table TST_ABC_STG from LZ_TEMP_TST_CLM_GNCCLMP table.
**************************************************************************************************/

INSERT INTO TST_ABC_STG
                        (
                         COA_ASGNMNT_RSN_CD
                        ,CLM_ADJSTMNT_KEY
/*As part of June Release, Added New Column SRC_CMPNY_CD:RIM#249094*/
						,SRC_CMPNY_CD
                        ,CLM_LINE_COA_EFCTV_DT
                        ,CLM_LINE_COA_TRMNTN_DT
                        ,CLM_LINE_NBR
                        ,CLM_SOR_CD
                        ,CLM_LINE_SOR_DTM
                        ,CMPNY_CF_CD
                        ,CRCTD_LOAD_LOG_KEY
                        ,DTL_PROD_CF_CD
                        ,FUNDG_CF_CD
                        ,LOAD_LOG_KEY
                        ,MBU_CF_CD
                        ,PROD_CF_CD
                        ,SRC_COA_ASGNMNT_RSN_CD
                        ,SRC_SYS_COA_KEY
                        ,SOR_DTM
                        ,TRNSCTN_CD
                        ,TRNSCTN_DTM
                        ,UPDTD_LOAD_LOG_KEY

                        )


                SELECT
                                '01' AS COA_ASGNMNT_RSN_CD
                                ,CLMP.CLM_ADJSTMNT_KEY AS CLM_ADJSTMNT_KEY
/*As part of June Release, Added New Column DDC_CD_COMPANY_CD AS SRC_CMPNY_CD:RIM#249094*/
								,CLMP.DDC_CD_COMPANY_CD AS SRC_CMPNY_CD
                                ,CASE 
                                        WHEN  CLMP.DDC_CD_CLM_COMPL_DTE>10000000 AND CLMP.DDC_CD_CLM_COMPL_DTE<100000000 
                                        THEN CAST(CAST(CLMP.DDC_CD_CLM_COMPL_DTE AS VARCHAR(8)) AS DATE FORMAT 'YYYYMMDD') 
                                        ELSE CAST('8888-12-31' AS DATE) 
                                END AS CLM_LINE_COA_EFCTV_DT
                                ,'8888-12-31'  AS CLM_LINE_COA_TRMNTN_DT
                                ,CASE 
                                        WHEN OUT_GTT.DDC_DTL_LNE_NBR IS NULL OR OUT_GTT.DDC_DTL_LNE_NBR <=0 THEN 'UNK'
                                        WHEN OUT_GTT.DDC_DTL_LNE_NBR > 0 AND OUT_GTT.DDC_DTL_LNE_NBR < 10 THEN
                                                '0'||CAST(CAST(OUT_GTT.DDC_DTL_LNE_NBR AS BIGINT) AS VARCHAR(6))
                                        ELSE CAST(CAST(OUT_GTT.DDC_DTL_LNE_NBR AS BIGINT) AS VARCHAR(6)) 
                                END AS CLM_LINE_NBR 
                                ,'$LZ2CSA_CLM_SOR_CD' AS CLM_SOR_CD
                                ,'$LZ2CSA_CLM_HIGH_DATE_TIME' AS CLM_LINE_SOR_DTM
/***************** HIX OCT 2013 RELEASE *******************************************************/
                                ,CASE 
                                        WHEN     ((NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD='')
                                             AND (NATP1.DDC_NAT_EA1_MBU_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_MBU_CHARTFLD='')
					     AND (NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD='')
					     AND (NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD=''))
						 /***************** START-Added as a part of RIM#412363 to avoid Invalid COA in CLM TRAIN *******************/
		                 OR 
		                 (
		                 SUBSTR(NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD,1,1) <> 'G'
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD)) <> 5
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_MBU_CHARTFLD)) <> 6
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD)) <> 2
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD)) <> 5
		                 )
						 /***************** END-Added as a part of RIM#412363 to avoid Invalid COA in CLM TRAIN *******************/

                                        THEN  
                                           CASE 
                                                WHEN  (WLP.SRC_SYS_COA_KEY IS NULL OR WLP.SRC_SYS_COA_KEY='') 
					        THEN 'UNK' 
					        ELSE WLP.NEW_CMPNY_CD
                                           END
                                        ELSE 
                                           CASE 
                                                WHEN  (NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD='')
                                                THEN 'UNK'
                                                ELSE NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD 
                                           END
                                END AS CMPNY_CF_CD
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/
                                ,0 AS CRCTD_LOAD_LOG_KEY
/***************** HIX OCT 2013 RELEASE *******************************************************/
                                ,CASE 
                                        WHEN  (WLP.SRC_SYS_COA_KEY IS NULL OR WLP.SRC_SYS_COA_KEY='') 
				        THEN 'NA' 
				        ELSE WLP.DTL_PROD_CF_CD
                                 END AS DTL_PROD_CF_CD

				,CASE 
                                        WHEN     ((NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD='')
                                             AND (NATP1.DDC_NAT_EA1_MBU_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_MBU_CHARTFLD='')
					     AND (NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD='')
					     AND (NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD=''))
						 /***************** START-Added as a part of RIM#412363 to avoid Invalid COA in CLM TRAIN *******************/
		                 OR 
		                 (
		                 SUBSTR(NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD,1,1) <> 'G'
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD)) <> 5
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_MBU_CHARTFLD)) <> 6
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD)) <> 2
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD)) <> 5
						 )
                        /***************** END-Added as a part of RIM#412363 to avoid Invalid COA in CLM TRAIN *******************/
                                        THEN  
                                           CASE 
                                                WHEN  (WLP.SRC_SYS_COA_KEY IS NULL OR WLP.SRC_SYS_COA_KEY='') 
					        THEN 'UNK' 
					        ELSE WLP.NEW_FUNDG_TYPE_CD
                                            END
                                        ELSE
                                           CASE 
                                                WHEN  (NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD='')
                                                THEN 'UNK'
                                                ELSE NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD 
                                           END
                                END AS FUNDG_CF_CD
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/

				,CLMP.CSA_LOAD_LOG_KEY AS LOAD_LOG_KEY
/***************** HIX OCT 2013 RELEASE *******************************************************/
				,CASE 
                                        WHEN     ((NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD='')
                                             AND (NATP1.DDC_NAT_EA1_MBU_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_MBU_CHARTFLD='')
					     AND (NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD='')
					     AND (NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD=''))
						 /*****************START- Added as a part of RIM#412363 to avoid Invalid COA in CLM TRAIN *******************/
		                 OR 
		                 (
		                 SUBSTR(NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD,1,1) <> 'G'
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD)) <> 5
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_MBU_CHARTFLD)) <> 6
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD)) <> 2
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD)) <> 5
						 )
						 /*****************END- Added as a part of RIM#412363 to avoid Invalid COA in CLM TRAIN *******************/

                                       THEN  
                                           CASE 
                                                WHEN  (WLP.SRC_SYS_COA_KEY IS NULL OR WLP.SRC_SYS_COA_KEY='') 
					        THEN 'UNK' 
					        ELSE WLP.NEW_MBU_CF_CD
                                           END
                                       ELSE
                                           CASE 
                                                WHEN  (NATP1.DDC_NAT_EA1_MBU_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_MBU_CHARTFLD='')
                                                THEN 'UNK'
                                                ELSE NATP1.DDC_NAT_EA1_MBU_CHARTFLD 
                                           END
                                END AS MBU_CF_CD

				,CASE 
                                        WHEN     ((NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD='')
                                             AND (NATP1.DDC_NAT_EA1_MBU_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_MBU_CHARTFLD='')
					     AND (NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD='')
					     AND (NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD=''))
						 /*****************START- Added as a part of RIM#412363 to avoid Invalid COA in CLM TRAIN *******************/
		                 OR 
		                 (
		                 SUBSTR(NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD,1,1) <> 'G'
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD)) <> 5
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_MBU_CHARTFLD)) <> 6
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD)) <> 2
		                 OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD)) <> 5
						 )
						 
						 /*****************END- Added as a part of RIM#412363 to avoid Invalid COA in CLM TRAIN *******************/

                                       THEN  
                                           CASE 
                                                WHEN  (WLP.SRC_SYS_COA_KEY IS NULL OR WLP.SRC_SYS_COA_KEY='') 
					        THEN 'UNK' 
					        ELSE WLP.NEW_PROD_CF_CD
                                           END
                                       ELSE   
				           NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD
                                END AS PROD_CF_CD
								
								/****START- Modification as a part of RIM#412363 ******************/
							,CASE 
							WHEN     ((NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD='')
							AND (NATP1.DDC_NAT_EA1_MBU_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_MBU_CHARTFLD='')
							AND (NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD='')
							AND (NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD IS NULL OR NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD=''))
							
							OR 
							(
							SUBSTR(NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD,1,1) <> 'G'
							OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_COMPANY_CHARTFLD)) <> 5
							OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_MBU_CHARTFLD)) <> 6
							OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_FUND_TYPE_CHARTFLD)) <> 2
							OR LENGTH(TRIM(NATP1.DDC_NAT_EA1_PRODUCT_CHARTFLD)) <> 5
							)
							
							THEN  
							CASE 
								WHEN  (WLP.SRC_SYS_COA_KEY IS NULL OR WLP.SRC_SYS_COA_KEY='') 
								THEN 'UNK' 
								ELSE 'LOBLKUP'
							END
							ELSE 'TRAIN'
							END AS SRC_COA_ASGNMNT_RSN_CD	                     
						 ,CASE
                                        WHEN (WLP.SRC_SYS_COA_KEY IS NULL OR WLP.SRC_SYS_COA_KEY='') 
                                 THEN 
/***************** HIX OCT 2013 RELEASE *******************************************************/
                                       CASE 
                                             WHEN     ((NATP1.DDC_NAT_EA1_EXCHANGE_IND IS NULL OR NATP1.DDC_NAT_EA1_EXCHANGE_IND='')
                                                  AND (NATP1.DDC_NAT_EA1_CONT_METAL_LVL IS NULL OR NATP1.DDC_NAT_EA1_CONT_METAL_LVL='')
					          AND (NATP1.DDC_NAT_EA1_CERTFN_IND IS NULL OR NATP1.DDC_NAT_EA1_CERTFN_IND=''))
                                            THEN
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/
					        MD5('$LZ2CSA_CLM_SOR_CD'||'_'||'UNK'||'_'||TRIM(DDC_CD_SLC_CDE)||'_'||SUBSTR(TRIM(DDC_CD_FULL_MBU_CDE),1,3)||'_'|| 
                                                    TRIM(DDC_CD_MK_FUND_TYPE)||'_'||'X'||'_'||TRIM(DDC_CD_PRIM_COV_CDE)||'_'||
                                                    TRIM(DDC_CD_PRIM_NET_CDE)) 
/***************** HIX OCT 2013 RELEASE *******************************************************/
                                            ELSE
					        MD5('$LZ2CSA_CLM_SOR_CD'||'_'||'UNK'||'_'||TRIM(DDC_CD_SLC_CDE)||'_'||SUBSTR(TRIM(DDC_CD_FULL_MBU_CDE),1,3)||'_'|| 
                            TRIM(DDC_CD_MK_FUND_TYPE)||'_'||'X'||'_'||TRIM(DDC_CD_PRIM_COV_CDE)||'_'||
                            TRIM(DDC_CD_PRIM_NET_CDE)||'_'||
						    TRIM(DDC_NAT_EA1_EXCHANGE_IND)||'_'||
						    TRIM(DDC_NAT_EA1_CONT_METAL_LVL)||'_'||
						    TRIM(DDC_NAT_EA1_CERTFN_IND))
				        END
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/					
                                ELSE WLP.SRC_SYS_COA_KEY

                                END AS SRC_SYS_COA_KEY
                                ,CLMP.TRNSCTN_DTM  AS SOR_DTM
                                ,'I' AS TRNSCTN_CD
                                ,'$LZ2CSA_CLM_HIGH_DATE_TIME'  AS TRNSCTN_DTM
                                ,CLMP.CSA_LOAD_LOG_KEY AS UPDTD_LOAD_LOG_KEY                                    
                                
                
                                                        
  FROM  LZ_TEMP_TST_CLM_GNCCLMP CLMP
                
/***************************************************************************************************
INNER JOIN BETWWEN LZ_TEMP_TST_CLM_GNCCLMP AND  LZ_TEMP_TST_CLM_ROLLDOWN_OUT2 
****************************************************************************************************/   
                
                INNER JOIN LZ_TEMP_TST_CLM_ROLLDOWN_OUT2 OUT_GTT
                        
                                ON
                                        CLMP.DDC_EXT_DCN_CC = OUT_GTT.DDC_EXT_DCN_CC 
                                AND     CLMP.DDC_EXT_DCN_NO= OUT_GTT.DDC_EXT_DCN_NO 
                                AND     CLMP.DDC_EXT_DCN_ITM_CDE =OUT_GTT.DDC_EXT_DCN_ITM_CDE
                                AND     CLMP.DDC_EXT_SEQ_NUMBER= OUT_GTT.DDC_EXT_SEQ_NUMBER
                                AND     CLMP.DDC_CD_CLM_COMPL_DTE = OUT_GTT.DDC_CD_CLM_COMPL_DTE
                                AND     CLMP.LOAD_LOG_KEY=OUT_GTT.LOAD_LOG_KEY

/***************** HIX OCT 2013 RELEASE *******************************************************/
                LEFT OUTER JOIN LZ_TEMP_TST_CLM_NATP_EA1_CF_CHK NATP1
		ON         CLMP.DDC_EXT_DCN_CC      = NATP1.DDC_EXT_DCN_CC
		AND        CLMP.DDC_EXT_DCN_NO      = NATP1.DDC_EXT_DCN_NO
		AND        CLMP.DDC_EXT_DCN_ITM_CDE = NATP1.DDC_EXT_DCN_ITM_CD
		AND        CLMP.DDC_EXT_SEQ_NUMBER  = NATP1.DDC_EXT_SEQ_NBR
		AND        CLMP.LOAD_LOG_KEY    = NATP1.LOAD_LOG_KEY
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/
/************************************************************************************************
LOOK UP ON  WLP_CNVRT_LOB
 *************************************************************************************************/
   LEFT OUTER JOIN         (SELECT   
                                WCL.NEW_CMPNY_CD,
                                WCL.NEW_FUNDG_TYPE_CD,
                                WCL.NEW_MBU_CF_CD,
                                WCL.NEW_PROD_CF_CD, 
                                WCL.DTL_PROD_CF_CD,
                                WCL.SRC_SYS_COA_KEY,
                                WCL.OLD_LOB,
                                /***Added as a part of HIX Aug -2013 Release ***/
                                WCL.EXCHNG_IND_CD,
                                WCL.EXCHNG_METAL_TYPE_CD,
                                WCL.EXCHNG_CERTFN_CD
                                /**********************************************/
                                FROM WLP_CNVRT_LOB WCL
                                QUALIFY ROW_NUMBER() OVER (PARTITION BY OLD_LOB,EXCHNG_IND_CD, EXCHNG_METAL_TYPE_CD, EXCHNG_CERTFN_CD
                                                                 ORDER BY VRSN_OPEN_DT DESC )=1
                                
                                )  AS  WLP       
                                ON   WLP.OLD_LOB= CLMP.OLD_LOB
				AND  WLP.EXCHNG_IND_CD=NATP1.DDC_NAT_EA1_EXCHANGE_IND
                                AND  WLP.EXCHNG_METAL_TYPE_CD=NATP1.DDC_NAT_EA1_CONT_METAL_LVL
                                AND  WLP.EXCHNG_CERTFN_CD=NATP1.DDC_NAT_EA1_CERTFN_IND
/**************************************************************************************************
FILTERING RECORDS FOR NON-PENDED CLAIMS
**************************************************************************************************/

                       WHERE CLMP.DDC_CD_CURR_STS_CDE IN ('88','99')
          
                
;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/


/**************************************************************************************************
STEP 5 :INSERT DATA INTO THE table COA_WLP_LOB 
**************************************************************************************************/


INSERT INTO WORK_COA_CUST_LOB_STG 
                (
                SRC_SYS_COA_KEY ,
                SRC_SOR_CD ,
                WLP_LOB_CMPNY_CD ,
                WLP_LOB_LCTN_LOB_CD ,
                WLP_LOB_MBU_CD ,
                WLP_LOB_FUNDG_TYPE_CD ,
                WLP_LOB_HRA_FUNDG_TYPE_CD,
                WLP_LOB_CVRG_CD ,
                WLP_LOB_NTWK_CD,
                LOAD_LOG_KEY,
                SOR_DTM ,
                CRCTD_LOAD_LOG_KEY,
                UPDTD_LOAD_LOG_KEY,
                TRNSCTN_CD,
                TRNSCTN_DTM
/***************** HIX OCT 2013 RELEASE *******************************************************/
               ,EXCHNG_IND_CD
               ,EXCHNG_METAL_TYPE_CD
               ,EXCHNG_CERTFN_CD
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/
                )


SELECT
 /***************** HIX OCT 2013 RELEASE *******************************************************/
        CASE  WHEN     ((NATP1.DDC_NAT_EA1_EXCHANGE_IND IS NULL OR NATP1.DDC_NAT_EA1_EXCHANGE_IND = '')
                   AND (NATP1.DDC_NAT_EA1_CONT_METAL_LVL IS NULL OR NATP1.DDC_NAT_EA1_CONT_METAL_LVL = '')
                   AND (NATP1.DDC_NAT_EA1_CERTFN_IND IS NULL OR NATP1.DDC_NAT_EA1_CERTFN_IND = ''))
                                
              THEN      
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/
                 MD5('808'||'_'||'UNK'||'_'||TRIM(CLMP.DDC_CD_SLC_CDE)||'_'||SUBSTR(TRIM(CLMP.DDC_CD_FULL_MBU_CDE),1,3)||'_'|| 
                                                 TRIM(CLMP.DDC_CD_MK_FUND_TYPE)||'_'||'X'||'_'||TRIM(CLMP.DDC_CD_PRIM_COV_CDE)||'_'||
                                                 TRIM(CLMP.DDC_CD_PRIM_NET_CDE)) 
/***************** HIX OCT 2013 RELEASE *******************************************************/
              ELSE
                 MD5('808'||'_'||'UNK'||'_'||TRIM(CLMP.DDC_CD_SLC_CDE)||'_'||SUBSTR(TRIM(CLMP.DDC_CD_FULL_MBU_CDE),1,3)||'_'|| 
                                                 TRIM(CLMP.DDC_CD_MK_FUND_TYPE)||'_'||'X'||'_'||TRIM(CLMP.DDC_CD_PRIM_COV_CDE)||'_'||
                                                 TRIM(CLMP.DDC_CD_PRIM_NET_CDE)||'_'||
                                                 TRIM(NATP1.DDC_NAT_EA1_EXCHANGE_IND)||'_'||
                                                 TRIM(NATP1.DDC_NAT_EA1_CONT_METAL_LVL)||'_'||
                                                 TRIM(NATP1.DDC_NAT_EA1_CERTFN_IND)
                                                 )
              END
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/
                AS SRC_SYS_COA_KEY
                        
                ,'$LZ2CSA_CLM_SOR_CD' AS SRC_SOR_CD
                             
                ,'UNK' AS WLP_LOB_CMPNY_CD
                ,TRIM(CLMP.DDC_CD_SLC_CDE) AS WLP_LOB_LCTN_LOB_CD
                ,SUBSTR(TRIM(CLMP.DDC_CD_FULL_MBU_CDE),1,3) AS WLP_LOB_MBU_CD
                ,TRIM(CLMP.DDC_CD_MK_FUND_TYPE) AS WLP_LOB_FUNDG_TYPE_CD
                ,'X' AS WLP_LOB_HRA_FUNDG_TYPE_CD
                ,TRIM(CLMP.DDC_CD_PRIM_COV_CDE) AS WLP_LOB_CVRG_CD
                ,TRIM(CLMP.DDC_CD_PRIM_NET_CDE) AS WLP_LOB_NTWK_CD
                ,CLMP.CSA_LOAD_LOG_KEY AS  LOAD_LOG_KEY
                ,'$LZ2CSA_CLM_HIGH_DATE_TIME' AS SOR_DTM
                ,0 AS CRCTD_LOAD_LOG_KEY
                ,CLMP.CSA_LOAD_LOG_KEY AS UPDTD_LOAD_LOG_KEY         
                ,'I' AS TRNSCTN_CD
                ,'$LZ2CSA_CLM_HIGH_DATE_TIME' AS TRNSCTN_DTM
/***************** HIX OCT 2013 RELEASE *******************************************************/
                ,CASE
                     WHEN NATP1.DDC_NAT_EA1_EXCHANGE_IND IS NULL THEN ' ' 
		     ELSE NATP1.DDC_NAT_EA1_EXCHANGE_IND 
                 END AS EXCHNG_IND_CD
                ,CASE
                     WHEN NATP1.DDC_NAT_EA1_CONT_METAL_LVL IS NULL THEN ' ' 
		     ELSE NATP1.DDC_NAT_EA1_CONT_METAL_LVL 
                 END AS EXCHNG_METAL_TYPE_CD
                ,CASE
                     WHEN NATP1.DDC_NAT_EA1_CERTFN_IND IS NULL THEN ' ' 
		     ELSE NATP1.DDC_NAT_EA1_CERTFN_IND 
                 END AS EXCHNG_CERTFN_CD                                
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/
                                
                                                        
  FROM  LZ_TEMP_TST_CLM_GNCCLMP CLMP

/***************** HIX OCT 2013 RELEASE *******************************************************/  

LEFT OUTER JOIN LZ_TEMP_TST_CLM_NATP_EA1_CF_CHK  NATP1
ON         CLMP.DDC_EXT_DCN_CC      = NATP1.DDC_EXT_DCN_CC
AND        CLMP.DDC_EXT_DCN_NO      = NATP1.DDC_EXT_DCN_NO
AND        CLMP.DDC_EXT_DCN_ITM_CDE = NATP1.DDC_EXT_DCN_ITM_CD
AND        CLMP.DDC_EXT_SEQ_NUMBER  = NATP1.DDC_EXT_SEQ_NBR
AND        CLMP.LOAD_LOG_KEY    = NATP1.LOAD_LOG_KEY
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/

                
/************************************************************************************************
LOOK UP ON  WLP_CNVRT_LOB
 *************************************************************************************************/
 LEFT OUTER JOIN         (SELECT   
                                WCL.SRC_SYS_COA_KEY,
                                WCL.OLD_LOB,
                                /***Added as a part of HIX Aug -2013 Release ***/
                                WCL.EXCHNG_IND_CD,
                                WCL.EXCHNG_METAL_TYPE_CD,
                                WCL.EXCHNG_CERTFN_CD
                                /**********************************************/
                                FROM WLP_CNVRT_LOB WCL
                                QUALIFY ROW_NUMBER() OVER (PARTITION BY OLD_LOB,EXCHNG_IND_CD, EXCHNG_METAL_TYPE_CD, EXCHNG_CERTFN_CD
                                                                 ORDER BY VRSN_OPEN_DT DESC )=1
                                
                                )  AS  WLP       
                                ON   CLMP.OLD_LOB= WLP.OLD_LOB
				AND  WLP.EXCHNG_IND_CD=NATP1.DDC_NAT_EA1_EXCHANGE_IND
                                AND  WLP.EXCHNG_METAL_TYPE_CD=NATP1.DDC_NAT_EA1_CONT_METAL_LVL
                                AND  WLP.EXCHNG_CERTFN_CD=NATP1.DDC_NAT_EA1_CERTFN_IND


/**************************************************************************************************
FILTERING RECORDS FOR NON-PENDED CLAIMS
**************************************************************************************************/
WHERE CLMP.DDC_CD_CURR_STS_CDE IN ('88','99') 
AND  (WLP.SRC_SYS_COA_KEY IS NULL OR WLP.SRC_SYS_COA_KEY='') 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18;


/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/**************************************************************************************************
STEP 7: INSERT DATA INTO THE table COA_WLP_LOB 
**************************************************************************************************/

INSERT INTO COA_CUST_LOB_STG 
                (
                SRC_SYS_COA_KEY ,
                SRC_SOR_CD ,
                WLP_LOB_CMPNY_CD ,
                WLP_LOB_LCTN_LOB_CD ,
                WLP_LOB_MBU_CD ,
                WLP_LOB_FUNDG_TYPE_CD ,
                WLP_LOB_HRA_FUNDG_TYPE_CD,
                WLP_LOB_CVRG_CD ,
                WLP_LOB_NTWK_CD,
                LOAD_LOG_KEY,
                SOR_DTM ,
                CRCTD_LOAD_LOG_KEY ,
                UPDTD_LOAD_LOG_KEY,
                TRNSCTN_CD,
                TRNSCTN_DTM
/***************** HIX OCT 2013 RELEASE *******************************************************/
	       ,EXCHNG_IND_CD
	       ,EXCHNG_METAL_TYPE_CD
	       ,EXCHNG_CERTFN_CD
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/
                )
SELECT 

		GTT.SRC_SYS_COA_KEY ,
                GTT.SRC_SOR_CD ,
                GTT.WLP_LOB_CMPNY_CD ,
                GTT.WLP_LOB_LCTN_LOB_CD ,
                GTT.WLP_LOB_MBU_CD ,
                GTT.WLP_LOB_FUNDG_TYPE_CD ,
                GTT.WLP_LOB_HRA_FUNDG_TYPE_CD,
                GTT.WLP_LOB_CVRG_CD ,
                GTT.WLP_LOB_NTWK_CD,
                GTT.LOAD_LOG_KEY,
                GTT.SOR_DTM ,
                GTT.CRCTD_LOAD_LOG_KEY ,
                GTT.UPDTD_LOAD_LOG_KEY,
                GTT.TRNSCTN_CD,
                GTT.TRNSCTN_DTM,
/***************** HIX OCT 2013 RELEASE *******************************************************/
	        GTT.EXCHNG_IND_CD,
	        GTT.EXCHNG_METAL_TYPE_CD,
	        GTT.EXCHNG_CERTFN_CD
/***************** End of the changes for HIX OCT 2013 RELEASE ********************************/
FROM WORK_COA_CUST_LOB_STG GTT

LEFT OUTER JOIN COA_WLP_LOB COA_LOB
ON  COA_LOB.SRC_SYS_COA_KEY=GTT.SRC_SYS_COA_KEY

WHERE COA_LOB.SRC_SYS_COA_KEY IS NULL OR COA_LOB.SRC_SYS_COA_KEY='';

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS 
/***************** Error Handling ********************************/

/************AUDIT BALANCING********************/


/* ************************************************************************************************
STEP 1: CHECKING FOR CSA TABLE SOURCE COUNT USING THE SAME QUERY THAT HAS BEEN USED FOR LOADING 
        DATA IN THE CSA TABLE.
***************************************************************************************************/


INSERT  INTO  RZ_AUDT_STTSTC
(
AUDT_RULE_ID,
EVNT_DTM ,
PRD_STRT_DT,
PRD_END_DT,
FILE_NM,
SESN_NM,
MAPG_NM ,
RCRD_CNT,
CLMN_TOTL,
TBL_TOTL,
LOAD_LOG_KEY,
LOAD_PRCS_CD,
TBL_NM
)


SELECT
 AUDT_RULE_ID AS AUDT_RULE_ID
,CURRENT_TIMESTAMP AS EVNT_DTM
,CURRENT_DATE AS PRD_STRT_DT
,CURRENT_DATE AS PRD_END_DT
,'N/A' AS FILE_NM
,'N/A' AS SESN_NM
,'N/A' AS MAPG_NM
, RCRD_CNT AS RCRD_CNT
,0 AS CLMN_TOTL
,0 AS TBL_TOTL
,LOAD_LOG.LOAD_LOG_KEY AS LOAD_LOG_KEY
,'$LZ2CSA_CLM_AUDT_LOAD_PRCS_CD' AS LOAD_PRCS_CD
,'TST_ABC_STG' AS TBL_NM
FROM
(
SELECT  COUNT(*) AS RCRD_CNT
FROM                                    

                
                 LZ_TEMP_TST_CLM_ROLLDOWN_OUT2 OUT_GTT
                        
                                
/**************************************************************************************************
STEP 4:FILTERING RECORDS FOR NON-PENDED CLAIMS
**************************************************************************************************/

                        WHERE OUT_GTT.DDC_CD_CURR_STS_CDE IN ('88','99')

) AS TEMP_COUNT

/**************************************************************************************************
STEP 7:JOIN WITH CSA_LOAD_LOG TABLE
**************************************************************************************************/


CROSS JOIN

(
SELECT  LOAD_LOG_KEY
FROM    CSA_LOAD_LOG
WHERE
            PBLSH_IND='$LZ2CSA_PBLSH_IND' 
        AND LOAD_END_DTM ='$LZ2CSA_CLM_HIGH_DATE_TIME' 
        AND SOR_CD= '$LZ2CSA_CLM_SOR_CD' 
        AND SUBJ_AREA_NM= '$LZ2CSA_CLM_SUBJ_AREA_NM' 
        AND WORK_FLOW_NM= '$LZ2CSA_CLM_WORK_FLOW_NM'
)LOAD_LOG

/**************************************************************************************************
JOIN WITH AUDT_BLNCG_RULE TABLE TO GET AUDT_RULE_ID.
**************************************************************************************************/

CROSS JOIN



( 
SELECT  AUDT_RULE_ID 
FROM    AUDT_BLNCG_RULE 
WHERE           TBL_NM = 'TST_ABC_STG'             
        AND     CLMN_NM = 'N/A'
        AND     ENVRNMNT_CD = '$ENVRNMNT_CD' 
        AND     SOR_CD='$LZ2CSA_CLM_SOR_CD'
) BALG_RULE

;


/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

CALL $DB_RFRSH_STAT_PROC.REFRESH_STTSTCS_TBL('$ETL_EDW_DB','COA_WLP_LOB','N',RTRN_CD,RTRN_CNT,MSG);


/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

INSERT INTO    AUDT_STTSTC
    (
        AUDT_RULE_ID                                    
        ,EVNT_DTM                                       
        ,PRD_STRT_DT                                    
        ,PRD_END_DT                                     
        ,FILE_NM                                                
        ,SESN_NM                                                
        ,MAPG_NM                                                
        ,RCRD_CNT                                       
        ,CLMN_TOTL                                      
        ,TBL_TOTL                                       
        ,LOAD_LOG_KEY                                   
        ,LOAD_PRCS_CD                                   
        ,TBL_NM
    )

    SELECT 
        AUDT_RULE_ID                                    
        ,EVNT_DTM                                       
        ,PRD_STRT_DT                                    
        ,PRD_END_DT                                     
        ,FILE_NM                                                
        ,SESN_NM                                                
        ,MAPG_NM                                                
        ,RCRD_CNT                                       
        ,CLMN_TOTL                                      
        ,TBL_TOTL                                       
        ,LOAD_LOG_KEY                                   
        ,LOAD_PRCS_CD                                   
        ,TBL_NM
    FROM     RZ_AUDT_STTSTC;

/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/***************** Error Handling *******************************
CLOSE and PUBLISH THE LLK
**************** Error Handling ********************************/

	UPDATE CSA_LOAD_LOG
	SET  PBLSH_IND='Y',
	LOAD_END_DTM = CURRENT_TIMESTAMP
	WHERE SOR_CD= '$LZ2CSA_CLM_SOR_CD' 
	AND SUBJ_AREA_NM= '$LZ2CSA_CLM_SUBJ_AREA_NM' 
	AND WORK_FLOW_NM= '$LZ2CSA_CLM_WORK_FLOW_NM'
	AND PBLSH_IND='N';
		
/***************** Error Handling ********************************/
.IF ERRORCODE <> 0 THEN .GOTO ERRORS
/***************** Error Handling ********************************/

/************************************** Exiting *******************************************/
.QUIT 0

/****************** If the query fails this error code value will be returned *********************/
.LABEL ERRORS

.QUIT ERRORCODE

EOF
# show AIX return code and exit with it
RETURN_CODE=$?
echo "script return code="$RETURN_CODE
exit $RETURN_CODE










