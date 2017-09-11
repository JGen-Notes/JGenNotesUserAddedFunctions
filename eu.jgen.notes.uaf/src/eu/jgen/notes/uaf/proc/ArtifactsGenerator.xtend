/**
 * [The "BSD license"]
 * Copyright (c) 2016, JGen Notes
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions 
 *    and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions 
 *    and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS 
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 */

package eu.jgen.notes.uaf.proc

import com.ca.gen.jmmi.Generation
import com.ca.gen.jmmi.GenerationManager
import com.ca.gen.jmmi.objs.Acblkbsd
import com.ca.gen.jmmi.objs.Acblkdef
import com.ca.gen.jmmi.objs.Attrusr
import com.ca.gen.jmmi.objs.Entvw
import com.ca.gen.jmmi.objs.Prdvw
import com.ca.gen.jmmi.schema.PrpTypeCode
import com.google.common.base.CaseFormat
import eu.jgen.notes.annot.desc.processor.AnnotationObject
import eu.jgen.notes.annot.desc.processor.DiagnosticKind
import eu.jgen.notes.annot.desc.processor.ProcessingEnvironment
import java.io.File
import java.util.List
import java.util.Set
import org.eclipse.xtext.TerminalRule
import org.eclipse.xtext.nodemodel.ILeafNode
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.xbase.XBooleanLiteral
import org.eclipse.xtext.xbase.XStringLiteral
import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotationElementValuePair

class ArtifactsGenerator {

	val static XML_FILE_NAME = "userfunctions.xml"
	val static PARAM_CGNAME = "CGName"
	val static PARAM_USESELEC = "useselec"
	val static PARAM_DBMSNAME = "dbmsname"
	val static PARAM_IMPL = "impl"
	val static TXT_FUNCTION_DIRECTORY = "com\\ca\\gen\\abrt\\functions"
	val static TXT_FUNCTION_PACKAGE_NAME = "com.ca.gen.abrt.functions"

	public static def void generateXml(Set<AnnotationObject> selection, ProcessingEnvironment processingEnv,
		String rootDirPath) {
		val writer = processingEnv.getFiler().openWriter(rootDirPath + "\\" + XML_FILE_NAME);
		var text = '''
			<?xml version="1.0" encoding="ISO-8859-1"?>
			<Gen_Functions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
			«FOR annotationObject : selection»
				«ArtifactsGenerator.generateXmlElement(annotationObject)»
			«ENDFOR»
			</Gen_Functions>
		'''
		writer.write(text);
		writer.close();
		processingEnv.getMessager().printMessage(DiagnosticKind.INFO,
			"XML file for " + selection.size() + " function(s) created.");
	}

	public static def String generateXmlElement(AnnotationObject annotationObject) {
		var desc = ArtifactsGenerator.extractCommentFromAnnotation(annotationObject)
		val acblkbsd = annotationObject.getGenObject as Acblkbsd
		var text = '''
			<Advantage_Gen_Function>
				<Name>«acblkbsd.getTextProperty(PrpTypeCode.NAME)»</Name>
					<Description>«desc»</Description>
					«ArtifactsGenerator.createXMLGenSpecific(annotationObject)»
					<IMPORTS>
						«ArtifactsGenerator.createXMLImport(annotationObject)»
					</IMPORTS>
					<EXPORTS>
						«findExport(annotationObject)»
					</EXPORTS>
			</Advantage_Gen_Function>
		'''
		return text;
	}

	private def static String findExport(AnnotationObject annotationObject) {
		val entvw = (annotationObject.genObject as Acblkbsd).followGrpby.followCntouts.followContains.get(0) as Entvw
		val prdvw = entvw.followDtlbyp.get(0)
		var text = '''
			<Export>
								 <ENTVW>
								  <NAME>  «entvw.getTextProperty(PrpTypeCode.NAME)»</NAME>
								 </ENTVW>
								«ArtifactsGenerator.createXMLAttrusr(prdvw.followSees, "RESULT")»
								«ArtifactsGenerator.createXMLViewimp(prdvw.followSees)»
			</Export>
		'''
		return text
	}

	private def static String createXMLImport(AnnotationObject annotationObject) {
		val imps = (annotationObject.genObject as Acblkbsd).followGrpby.followCntinps.followContains
		var bigtext = new StringBuffer()
		var param = 1;
		for (element : imps) {
			var list = (element as Entvw).followDtlbyp
			for (prdvw : list) {
				var text = '''
					<Import>
					 <ENTVW>
					  <NAME>  «element.getTextProperty(PrpTypeCode.NAME)»</NAME>
					 </ENTVW>
					«ArtifactsGenerator.createXMLAttrusr(prdvw.followSees, "PARAM"+ param)»
					«ArtifactsGenerator.createXMLViewimp(prdvw.followSees)»
					</Import>
				'''
				bigtext.append(text)
				param++
			}
		}
		return bigtext.toString
	}

	private def static String createXMLAttrusr(Attrusr attrusr, String name) {
		var text = '''
			<ATTRUSR>
								<DOMAN>«attrusr.getTextProperty(PrpTypeCode.DOMAN)»</DOMAN>
								<CASESENS>«attrusr.getTextProperty(PrpTypeCode.CASESENS)»</CASESENS>
								<NAME>«name»</NAME>
								<LEN>«attrusr.getIntProperty(PrpTypeCode.LEN)»</LEN>
								<DECPLC>«attrusr.getIntProperty(PrpTypeCode.DECPLC)»</DECPLC>
			</ATTRUSR>
		'''

		return text
	}

	private def static String createXMLViewimp(Attrusr attrusr) {
		var text = '''
			<VIEWIMP>
								<LENGTH>«attrusr.getIntProperty(PrpTypeCode.LEN)»</LENGTH>
								<IMPTYPE>«findImptype(attrusr)»</IMPTYPE>
								<MISSING>N</MISSING>
			</VIEWIMP>
		'''
		return text
	}
	
	private def static String findImptype(Attrusr attrusr) {
		val doman = String.valueOf(attrusr.doman)
		if (doman == 'T') { // Text
			return "X"
		}
		if (doman == "N" && attrusr.len <= 4 && attrusr.decplc == 0) { // Numeric
			return "S"
		}
		if (doman == "N" && attrusr.len <= 9 && attrusr.decplc == 0) { // Numeric
			return "I"
		}
		if (doman == "N" && attrusr.len > 9 && attrusr.decplc == 0) { // Numeric
			return "LongAttr"
		}
		if (doman == "N" && attrusr.len > 9 && attrusr.decplc != 0) { // Numeric
			return "F"
		}
		if (doman == 'D') { // Date
			return "D"
		}
		if (doman == 'M') { // Time
			return "T"
		}
		if (doman == 'Z') { // Mixed
			return "X"
		}
		if (doman == 'Q') { // Timestamp
			return "Q"
		}
		if (doman == 'B') { // Blob
			return "B"
		}
		if (doman == 'G') { // DBCS
			return "X"
		}
		return "?"
	}

	private static def String extractCommentFromAnnotation(AnnotationObject annotationObject) {
		var all = annotationObject.getAnnotation.eContainer.eResource.contents
		for (element : all) {
			var node = NodeModelUtils.getNode(element);
			for (ILeafNode leafNode : node.getLeafNodes()) {
				var grammarElement = leafNode.getGrammarElement();
				if ((grammarElement instanceof TerminalRule)) {
					var terminalRule = grammarElement as TerminalRule;
					var name = terminalRule.getName();
					if ("WS".equals(name)) {
					} else if ("SL_COMMENT".equals(name)) {
						return removeCommentMarkers(leafNode.text)
					} else if ("ML_COMMENT".equals(name)) {
						return removeCommentMarkers(leafNode.text)
					}
				}
			}
		}
		return ""
	}

	private static def String removeCommentMarkers(String comment) {
		comment.replace("/*", "").replace("*/", "").replace("//", "")
	}

	private static def String findExportDomain(AnnotationObject annotationObject) {
		val entvw = (annotationObject.genObject as Acblkbsd).followGrpby.followCntouts.followContains.get(0) as Entvw
		val prdvw = entvw.followDtlbyp.get(0) as Prdvw
		return String.valueOf(prdvw.followSees.getCharProperty(PrpTypeCode.DOMAN))
	}

	private static def String findOptionality(AnnotationObject annotationObject) {
		val entvw = (annotationObject.genObject as Acblkbsd).followGrpby.followCntouts.followContains.get(0) as Entvw
		val prdvw = entvw.followDtlbyp.get(0) as Prdvw
		return String.valueOf(prdvw.followSees.getCharProperty(PrpTypeCode.OPT))
	}

	private static def String createXMLGenSpecific(AnnotationObject annotationObject) {
		val pairs = annotationObject.getAnnotation().getElementValuePairs();
		var cgname = ""
		var useselec = false
		var dbmsname = "IEFDB"
		for (XAnnotationElementValuePair annotationElementValuePair : pairs) {
			if (annotationElementValuePair.getElement().getSimpleName() == PARAM_CGNAME) {
				cgname = (annotationElementValuePair.getValue() as XStringLiteral ).getValue()
			}
			if (annotationElementValuePair.getElement().getSimpleName() == PARAM_USESELEC) {
				useselec = (annotationElementValuePair.getValue() as XBooleanLiteral ).isTrue
			}
			if (annotationElementValuePair.getElement().getSimpleName() == PARAM_DBMSNAME) {
				dbmsname = (annotationElementValuePair.getValue() as XStringLiteral ).getValue()
			}
		}
		return '''
			<Domain>«findExportDomain(annotationObject)»</Domain>
			<Entity_Name>«cgname»</Entity_Name>
			<OPT>«findOptionality(annotationObject)»</OPT>
			<Gen_Specific>
						<CGName>«cgname»</CGName>
						«IF useselec»
							<USESELEC>Y</USESELEC>							
						«ENDIF»
						«IF !useselec»	<USESELEC>N</USESELEC>					
						«ENDIF»
						«IF useselec»
							<DBMSNAME>«dbmsname»</DBMSNAME>							
						«ENDIF»
						«IF !useselec»
							<DBMSNAME></DBMSNAME>					
						«ENDIF»					
			</Gen_Specific>				
		'''
	}

	public static def void processFunctions(Set<AnnotationObject> selection, ProcessingEnvironment processingEnv,
		String srcDirPath) {
		for (annotationObject : selection) {
			ArtifactsGenerator.createFuntionInJava(annotationObject, processingEnv, srcDirPath)
		}
	}

	private static def void createFuntionInJava(AnnotationObject annotationObject, ProcessingEnvironment processingEnv,
		String srcDirPath) {
		val pairs = annotationObject.getAnnotation().getElementValuePairs();
		var cgname = ""
		for (XAnnotationElementValuePair annotationElementValuePair : pairs) {
			if (annotationElementValuePair.getElement().getSimpleName() == PARAM_CGNAME) {
				cgname = (annotationElementValuePair.getValue() as XStringLiteral ).getValue()
			}
		}
		val path = createPackageFileStructure(processingEnv, srcDirPath, ArtifactsGenerator.TXT_FUNCTION_DIRECTORY)
		generateFunction(processingEnv, annotationObject, cgname, path)
		processingEnv.getMessager().printMessage(DiagnosticKind.INFO,
			"Function " + ArtifactsGenerator.TXT_FUNCTION_PACKAGE_NAME + "." + cgname + " generated.")
		if (processingEnv.getOptions().getOrDefault(UserAddedFunctionProcessor.OPT_TEST, " ") ==
			UserAddedFunctionProcessor.OPT_TEST || processingEnv.getOptions().getOrDefault(UserAddedFunctionProcessor.OPT_FORCE, " ") ==
			UserAddedFunctionProcessor.OPT_FORCE) {
			createFuntionTestClass(processingEnv, annotationObject, path, cgname)
			processingEnv.getMessager().printMessage(DiagnosticKind.WARNING,
				"Test class was regenerated. All previous modifications were lost.");
		}
	}

	private static def void createFuntionTestClass(ProcessingEnvironment processingEnv,
		AnnotationObject annotationObject, String srcDirPath, String cgname) {
		val path = createPackageFileStructure(processingEnv, srcDirPath, "test")
		generateFunctionTestClass(processingEnv, annotationObject, cgname, path)
		processingEnv.getMessager().printMessage(DiagnosticKind.INFO,
			"Function Test Class" + TXT_FUNCTION_PACKAGE_NAME + "." + cgname + "Tests" + " generated.")
	}

	private def static void generateFunctionTestClass(ProcessingEnvironment processingEnv,
		AnnotationObject annotationObject, String cgname, String path) {

		val acblkbsd = (annotationObject.genObject as Acblkbsd)
		val packname = findPackageName(acblkbsd)
		val mbrname = acblkbsd.followImplby.mbrname

		val List<Pair> listParams = createParametersImports(annotationObject)
		val exp = createParametersExport(annotationObject)
		val writer = processingEnv.getFiler().openWriter(path + "\\" + cgname + "Tests.java");
		var text = '''
			/**
			* Code generated by UserAddedFunctionProcessor
			*/
			package «TXT_FUNCTION_PACKAGE_NAME».test;
				
			import org.junit.AfterClass;
			import org.junit.BeforeClass;
			import org.junit.Test;
			import static org.junit.Assert.*;
				
			import «TXT_FUNCTION_PACKAGE_NAME».«cgname»;
			import com.ca.gen.vwrt.types.IntAttr;
			import com.google.inject.Guice;
			import com.google.inject.Injector;
				
			import eu.jgen.notes.ab.direct.mgr.ActionBlockModule;
			import eu.jgen.notes.ab.direct.mgr.DBMSType;
			import eu.jgen.notes.ab.direct.mgr.DirectException;
			import eu.jgen.notes.ab.direct.mgr.SessionContext;
			import eu.jgen.notes.ab.direct.mgr.SessionManager;
			import eu.jgen.notes.ab.direct.mgr.TransactionManagerType;
				
			import com.ca.gen.vwrt.types.IntAttr;
			import com.ca.gen.vwrt.types.ShortAttr;
			import com.ca.gen.vwrt.types.BlobAttr;
			import com.ca.gen.vwrt.types.TimestampAttr;
			import com.ca.gen.vwrt.types.DateAttr;
			import com.ca.gen.vwrt.types.TimeAttr;
			import com.ca.gen.vwrt.types.BigDecimalAttr;
			import com.ca.gen.vwrt.types.StringAttr;
			
				/**
					* @author  
					*
					*/	
				public  class «cgname»Tests {
					
					static Injector injector;
					private static SessionManager sessionManager;
					
				/**
				* @throws java.lang.Exception
				*/
				@BeforeClass
				public static void setUpBeforeClass() throws Exception {
					try {
						injector = Guice.createInjector(new ActionBlockModule());
						sessionManager = injector.getInstance(SessionManager.class);
						sessionManager.initialize(TransactionManagerType.None, DBMSType.None).begin();
						} catch (DirectException e) {
							e.printStackTrace();
						}
					}
					
				/**
				* @throws java.lang.Exception
				*/
				@AfterClass
				public static void tearDownAfterClass() throws Exception {
				}
			
				@Test
				public void sampleTest() {
					«IF exp !== null»
						«exp.type» result = «exp.type».getInstance(«IF exp.type == "BlobAttr"»999«ENDIF»);
					«ENDIF»
					«cgname».«cgname»(new Object(), new SessionContext(sessionManager.getGlobData()), sessionManager.getGlobData()
					«FOR pair : listParams BEFORE ',' SEPARATOR ','»
						«defaultValue(pair.type)»
					«ENDFOR»
					«IF exp !== null»
						,result
					«ENDIF»
					);
					assertTrue(false);
					}
						
				}
		'''
		writer.write(text)
		writer.close()
	}

	def private static String defaultValue(String type) {
		if (type == "int") {
			return "0";
		}
		if (type == "short") {
			return "(short) 0";
		}
		if (type == "String") {
			return '"value"';
		}
		if (type == "double") {
			return "(double) 0";
		}
		if (type == "byte[]") {
			return "null";
		}
		return ""
	}

	def static generateFunction(ProcessingEnvironment processingEnv, AnnotationObject annotationObject, String cgname,
		String path) {
		var isImplemented = false;
		val pairs = annotationObject.getAnnotation().getElementValuePairs();
		for (XAnnotationElementValuePair annotationElementValuePair : pairs) {
			if (annotationElementValuePair.getElement().getSimpleName() == PARAM_IMPL) {
				isImplemented = (annotationElementValuePair.getValue() as XBooleanLiteral).isTrue
			}
		}
		val acblkbsd = (annotationObject.genObject as Acblkbsd)
		val packname = findPackageName(acblkbsd)
		val mbrname = acblkbsd.followImplby.mbrname

		val List<Pair> listParams = createParametersImports(annotationObject)
		val exp = createParametersExport(annotationObject)
		val writer = processingEnv.getFiler().openWriter(path + "\\" + cgname + ".java");
		var text = '''
			/**
			* Code generated by UserAddedFunctionProcessor
			*/
				package «ArtifactsGenerator.TXT_FUNCTION_PACKAGE_NAME»;
				
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
				
			«IF listParams.size > 0 && isImplemented»
				import «packname».«mbrname»_IA;
				«ENDIF»
				«IF exp !== null && isImplemented»
					import «packname».«mbrname»_OA;
					«ENDIF»
					
					public final class «cgname» {
							
							  public static final void «cgname»(Object paramObject, IRuntimePStepContext paramIRuntimePStepContext, GlobData paramGlobData 
							 «FOR pair : listParams BEFORE ',' SEPARATOR ','»
							 	«pair.type» «pair.name» 
							 «ENDFOR»
							 «IF exp !== null»
							 	,«exp.type» «exp.name» 
							 «ENDIF»
							 ) {
							  
							   paramGlobData.getErrorData().setFunctionName("«cgname»");
							   paramGlobData.getErrorData().setErrorMessage("");
							   paramGlobData.getErrorData().setErrorMessageNumber((short)0);
							   
							   «IF isImplemented»
							   	«generateImplementation(processingEnv, annotationObject, listParams, exp, packname)»
							   «ENDIF»
							   «IF !isImplemented»
							   	// Insert your implementation code here.
							   «ENDIF»
							   
							  }
							
					}
				'''
		writer.write(text)
		writer.close()
	}

	private def static String findPackageName(Acblkbsd acblkbsd) {
		val list = acblkbsd.followOwnedby.followImplby
		for (techsys : list) {
			if (techsys.language == "JAVA" && techsys.opersys == "JVM") {
				return techsys.sysstrg
			}
		}
		return ""
	}

	def static String createPackageFileStructure(ProcessingEnvironment processingEnv, String srcDirPath,
		String packagepath) {
		val path = srcDirPath + "\\" + packagepath
		val packDir = new File(path);
		if (!packDir.exists()) {
			packDir.mkdirs();
			processingEnv.getMessager().printMessage(DiagnosticKind.INFO,
				"Creating  package sub-directories for functions: " + path);
		}
		return path;
	}

	public static def void generateActionBlock(Set<AnnotationObject> selection, ProcessingEnvironment processingEnv,
		String javaDirPath) {
		val generation = GenerationManager.getInstance(processingEnv.model);
		selection.forEach [ annotationObject |
			ArtifactsGenerator.expandUses(generation, processingEnv, javaDirPath,
				annotationObject.genObject as Acblkdef)
		]
	}

	private static def void expandUses(Generation generation, ProcessingEnvironment processingEnv, String javaDirPath,
		Acblkdef acblk) {
		val list = acblk.followContains
		for (acblkuse : list) {
			var acblkdef = acblkuse.followRefs
			ArtifactsGenerator.expandUses(generation, processingEnv, javaDirPath, acblkdef)
		}
		if (acblk instanceof Acblkbsd) {
			generation.generateActionBlock(generation.getModelContext(), acblk.id.value, javaDirPath, "", "ABC", "JVM",
				"JDBC", "INTERNET", "JAVA", "NO", "JAVAC", "YES");
			processingEnv.getMessager().printMessage(DiagnosticKind.INFO,
				"Implementation action block " + acblk.name + " generated.");
		}
	}

	public static def void generateProjectFile(ProcessingEnvironment processingEnv, String rootDirPath,
		String projectName) {
		val writer = processingEnv.getFiler().openWriter(rootDirPath + "\\" + ".project");
		var text = '''
			<?xml version="1.0" encoding="UTF-8"?>
			<projectDescription>
				<name>«projectName»</name>
				<comment></comment>
				<projects>
				</projects>
				<buildSpec>
					<buildCommand>
						<name>org.eclipse.jdt.core.javabuilder</name>
						<arguments>
						</arguments>
					</buildCommand>
					<buildCommand>
								<name>org.eclipse.pde.ManifestBuilder</name>
								<arguments>
								</arguments>
							</buildCommand>
					<buildCommand>
								<name>org.eclipse.pde.SchemaBuilder</name>
								<arguments>
								</arguments>
					</buildCommand>
				</buildSpec>
				
				<natures>
					<nature>org.eclipse.jdt.core.javanature</nature>
					<nature>org.eclipse.pde.PluginNature</nature>
				</natures>
			</projectDescription>
		'''
		writer.write(text);
		writer.close();
		processingEnv.getMessager().printMessage(DiagnosticKind.INFO, "Project file with Java nature created. ");
	}

	public static def void generateMetaInf(ProcessingEnvironment processingEnv, String rootDirPath) {
		val name = processingEnv.getOptions().get(UserAddedFunctionProcessor.OPT_LOCAL_NAME)
		val writer = processingEnv.getFiler().openWriter(rootDirPath + "\\META-INF\\" + "MANIFEST.MF");
		var text = '''
			Manifest-Version: 1.0
			Bundle-ManifestVersion: 2
			Bundle-Name: «name»
			Bundle-SymbolicName: your.name.UAF
			Bundle-Version: 1.0.0.qualifier
			Bundle-Vendor: JGen Notes
			Require-Bundle: org.eclipse.xtext.testing,
			 org.junit;bundle-version="4.12.0"
			Bundle-RequiredExecutionEnvironment: JavaSE-1.8
			Bundle-ActivationPolicy: lazy
			Import-Package: eu.jgen.notes.ab.direct.mgr
		'''
		writer.write(text);
		writer.close();
		processingEnv.getMessager().printMessage(DiagnosticKind.INFO, "MANIFEST.MF file created. ");
	}

	public static def void generateClasspathFile(ProcessingEnvironment processingEnv, String rootDirPath,
		String genlocation) {
		val writer = processingEnv.getFiler().openWriter(rootDirPath + "\\" + ".classpath");
		var text = '''
			<?xml version="1.0" encoding="UTF-8"?>
			<classpath>
				<classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER"/>
				<classpathentry kind="src" path="java"/>
				<classpathentry kind="src" path="src"/>
				<classpathentry kind="lib" path="«genlocation»/Gen/classes/abrt.jar"/>
				<classpathentry kind="lib" path="C:/Program Files (x86)/CA/Gen86Free/Gen/classes/csu.jar"/>
				<classpathentry kind="lib" path="C:/Program Files (x86)/CA/Gen86Free/Gen/classes/odc.jar"/>
				<classpathentry kind="lib" path="C:/Program Files (x86)/CA/Gen86Free/Gen/classes/vwrt.jar"/>
				<classpathentry kind="lib" path="C:/Program Files (x86)/CA/Gen86Free/Gen/classes"/>
				<classpathentry kind="con" path="org.eclipse.pde.core.requiredPlugins"/>
				<classpathentry kind="output" path="bin"/>
			</classpath>
		'''
		writer.write(text);
		writer.close();
		processingEnv.getMessager().printMessage(DiagnosticKind.INFO, "Classpath file with CA Gen libraries created. ");
	}

//	public static def List<String> createParameters(AnnotationObject annotationObject) {
//		val List<String> listParams = newArrayList()
//
//		return listParams;
//	}
	private static def List<Pair> createParametersImports(AnnotationObject annotationObject) {
		val List<Pair> listParams = newArrayList()
		val listEntvwImp = (annotationObject.genObject as Acblkbsd).followGrpby.followCntinps.followContains
		for (entvw : listEntvwImp) {
			var listPrdvw = (entvw as Entvw).followDtlbyp
			for (prdvw : listPrdvw) {
				var attrusr = prdvw.followSees as Attrusr
				var name = CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL,
					entvw.name + "_" + attrusr.followDscpa.name + "_" + attrusr.name)
				listParams.add(new Pair(name.toFirstLower, findType(attrusr)))
			}
		}
		return listParams
	}

	private static def Pair createParametersExport(AnnotationObject annotationObject) {
		val listEntvwExp = (annotationObject.genObject as Acblkbsd).followGrpby.followCntouts.followContains
		for (entvw : listEntvwExp) {
			var listPrdvw = (entvw as Entvw).followDtlbyp
			for (prdvw : listPrdvw) {
				var attrusr = prdvw.followSees as Attrusr
				var name = CaseFormat.UPPER_UNDERSCORE.to(CaseFormat.UPPER_CAMEL,
					entvw.name + "_" + attrusr.followDscpa.name + "_" + attrusr.name)
				return new Pair(name.toFirstLower, findTypeReturn(attrusr));
			}
		}
		return null;
	}

	private static def String findType(Attrusr attrusr) {
		val doman = String.valueOf(attrusr.doman)
		if (doman == 'T') { // Text
			return "String"
		}
		if (doman == 'N' && attrusr.len <= 4 && attrusr.decplc == 0) { // Numeric
			return "short"
		}
		if (doman == 'N' && attrusr.len <= 9 && attrusr.decplc == 0) { // Numeric
			return "int"
		}
		if (doman == 'N' && attrusr.len > 9 && attrusr.decplc != 0) { // Numeric
			return "double"
		}
		if (doman == 'D') { // Date
			return "int"
		}
		if (doman == 'M') { // Time
			return "int"
		}
		if (doman == 'Z') { // Mixed
			return "String"
		}
		if (doman == 'Q') { // Timestamp
			return "String"
		}
		if (doman == 'B') { // Blob
			return "byte[]"
		}
		if (doman == 'G') { // DBCS
			return "String"
		}
		return "?"
	}

	private def static String findTypeReturn(Attrusr attrusr) {
		val doman = String.valueOf(attrusr.doman)
		if (doman == 'T') { // Text
			return "StringAttr"
		}
		if (doman == "N" && attrusr.len <= 4 && attrusr.decplc == 0) { // Numeric
			return "ShortAttr"
		}
		if (doman == "N" && attrusr.len <= 9 && attrusr.decplc == 0) { // Numeric
			return "IntAttr"
		}
		if (doman == "N" && attrusr.len > 9 && attrusr.decplc == 0) { // Numeric
			return "LongAttr"
		}
		if (doman == "N" && attrusr.len > 9 && attrusr.decplc != 0) { // Numeric
			return "BigDecimalAttr"
		}
		if (doman == 'D') { // Date
			return "DateAttr"
		}
		if (doman == 'M') { // Time
			return "TimeAttr"
		}
		if (doman == 'Z') { // Mixed
			return "StringAttr"
		}
		if (doman == 'Q') { // Timestamp
			return "TimestampAttr"
		}
		if (doman == 'B') { // Blob
			return "BlobAttr"
		}
		if (doman == 'G') { // DBCS
			return "StringAttr"
		}
		return "?"
	}

	private def static String generateImplementation(ProcessingEnvironment processingEnv,
		AnnotationObject annotationObject, List<Pair> listParams, Pair exp, String packname) {
		val acblkdef = annotationObject.genObject as Acblkdef
		val mbrname = acblkdef.followImplby.mbrname
		var text = '''
			«IF listParams.size > 0»
				«mbrname»_IA w_ia =  «mbrname»_IA.getInstance();		
			«ENDIF»
			«IF exp !== null»			  
				«mbrname»_OA w_oa =  «mbrname»_OA.getInstance() ;
			«ENDIF»
			«FOR pair : listParams»
				w_ia.«pair.name.toFirstUpper» = «pair.name»;
			«ENDFOR»
			paramIRuntimePStepContext.useActionBlock("«packname».«mbrname»","«mbrname»"«IF listParams.size > 0»,w_ia«ENDIF»«IF listParams.size == 0»,null«ENDIF»«IF exp !== null»,w_oa«ENDIF»«IF exp === null»,null«ENDIF»);
			«IF exp !== null»
				«exp.name».set(w_oa.«exp.name.toFirstUpper»);
			«ENDIF»
		'''
		return text
	}

}
