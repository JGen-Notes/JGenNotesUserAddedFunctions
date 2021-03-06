/**
* Code generated by UserAddedFunctionProcessor
*/
	package com.ca.gen.abrt.functions;
	
	import com.ca.gen.abrt.ErrorData;
	import com.ca.gen.abrt.GlobData;
	import com.ca.gen.abrt.IRuntimePStepContext;
	import com.ca.gen.vwrt.types.IntAttr;
	import com.ca.gen.vwrt.types.ShortAttr;
	import com.ca.gen.vwrt.types.BlobAttr;
	import com.ca.gen.vwrt.types.TimestampAttr;
	import com.ca.gen.vwrt.types.DateAttr;
	import com.ca.gen.vwrt.types.TimeAttr;
	import com.ca.gen.vwrt.types.BigDecimalAttr;
	import com.ca.gen.vwrt.types.StringAttr;
	
import eu.jgen.notes.tstuaf1.samples.AB01_IA;
	import eu.jgen.notes.tstuaf1.samples.AB01_OA;
		
		public final class XFAB01 {
				
				  public static final void XFAB01(Object paramObject, IRuntimePStepContext paramIRuntimePStepContext, GlobData paramGlobData 
,				 int imp1IefSuppliedCount, 
				 int imp2IefSuppliedCount 
				 ,IntAttr expIefSuppliedCount 
				 ) {
				  
				   paramGlobData.getErrorData().setFunctionName("XFAB01");
				   paramGlobData.getErrorData().setErrorMessage("");
				   paramGlobData.getErrorData().setErrorMessageNumber((short)0);
				   
				   AB01_IA w_ia =  AB01_IA.getInstance();		
				   AB01_OA w_oa =  AB01_OA.getInstance() ;
				   w_ia.Imp1IefSuppliedCount = imp1IefSuppliedCount;
				   w_ia.Imp2IefSuppliedCount = imp2IefSuppliedCount;
				   paramIRuntimePStepContext.useActionBlock("eu.jgen.notes.tstuaf1.samples.AB01","AB01",w_ia,w_oa);
				   expIefSuppliedCount.set(w_oa.ExpIefSuppliedCount);
				   
				  }
				
		}
