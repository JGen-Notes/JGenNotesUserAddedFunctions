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
package eu.jgen.notes.uaf.proc;

import java.io.File;
import java.util.Set;

import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotation;

import eu.jgen.notes.annot.desc.processor.AbstractProcessor;
import eu.jgen.notes.annot.desc.processor.AnnotationObject;
import eu.jgen.notes.annot.desc.processor.DiagnosticKind;
import eu.jgen.notes.annot.desc.processor.ProcessingEnvironment;
import eu.jgen.notes.annot.desc.processor.ScanEnvironment;
import eu.jgen.notes.annot.desc.processor.SupportedAnnotationTypes;

@SupportedAnnotationTypes(value = { "eu.jgen.notes.uaf.proc.Function" })
public class UserAddedFunctionProcessor extends AbstractProcessor {
	
	private String rootDirPath;
	private String srcDirPath;	
	private String javaDirPath;	
	private String metaDirPath;	

	private static final String DIRECTORY_META = "\\META-INF";
	private static final String DIRECTORY_SRC = "\\src";
	private static final String DIRECTORY_GEN = "";
	public static final String OPT_NOTES_DIRECTORY = "directory";
	public static final String OPT_CAGEN_PATH = "cagenpath";
	public static final String OPT_LOCAL_NAME = "localname"; 
	public static final String OPT_FORCE = "-forceall";
	public static final String OPT_TEST = "-testonly";
	public static final String OPT_SOURCE = "-sourcesonly";

	public UserAddedFunctionProcessor() {
		super();
	}

	@Override
	public void init(ProcessingEnvironment processingEnv) {
		super.init(processingEnv);
	}

	@Override
	public boolean process(Set<XAnnotation> annotations, ScanEnvironment scanEnv) {		
		checkInfrastructure();
		if(processingEnv.getOptions().getOrDefault(OPT_SOURCE, " ").equals(OPT_SOURCE)) {
			Set<AnnotationObject> selection = scanEnv.getElementsAnnotatedWith(eu.jgen.notes.uaf.proc.Function.class);
			ArtifactsGenerator.generateActionBlock(selection, processingEnv, javaDirPath); 
			processingEnv.getMessager().printMessage(DiagnosticKind.WARNING, "Only action block sources will be regenerated.");	
		} else {
			String name = processingEnv.getOptions().get(UserAddedFunctionProcessor.OPT_LOCAL_NAME);
			ArtifactsGenerator.generateProjectFile(processingEnv, rootDirPath, name);
			ArtifactsGenerator.generateClasspathFile(processingEnv, rootDirPath,  processingEnv.getOptions().getOrDefault(OPT_CAGEN_PATH, "C:/Program Files (x86)/CA/Gen86Free"));
			Set<AnnotationObject> selection = scanEnv.getElementsAnnotatedWith(eu.jgen.notes.uaf.proc.Function.class);
			processingEnv.getMessager().printMessage(DiagnosticKind.INFO, "Found " + selection.size() + " function(s).");	
			ArtifactsGenerator.generateXml(selection, processingEnv, rootDirPath); 
			ArtifactsGenerator.processFunctions(selection, processingEnv, srcDirPath); 
			ArtifactsGenerator.generateActionBlock(selection, processingEnv, javaDirPath); 
			ArtifactsGenerator.generateMetaInf(processingEnv, rootDirPath);
		}
		return true;
	}

	private void checkInfrastructure() {
		String forceIndicator = processingEnv.getOptions().getOrDefault(OPT_FORCE, " ");
		if(forceIndicator.equals(OPT_FORCE)) {
			emptyDirectories();
			processingEnv.getMessager().printMessage(DiagnosticKind.WARNING, "All subdirectories were forced to be emptied.");	
		}
		rootDirPath = processingEnv.getOptions().getOrDefault(OPT_NOTES_DIRECTORY, "C:\\TEMP");
		File rootDir = new File(rootDirPath);
		if(!rootDir.exists()) {
			rootDir.mkdirs();
			processingEnv.getMessager().printMessage(DiagnosticKind.INFO, "Adding subdirectory. ");
		}
		srcDirPath = rootDirPath + DIRECTORY_SRC;
		File srcDir = new File(srcDirPath);
		if(!srcDir.exists()) {
			srcDir.mkdirs();
			processingEnv.getMessager().printMessage(DiagnosticKind.INFO, "Adding java functions subdirectory. ");
		}
		javaDirPath = rootDirPath + DIRECTORY_GEN;
		File javaDir = new File(javaDirPath);
		if(!javaDir.exists()) {
			javaDir.mkdirs();
			processingEnv.getMessager().printMessage(DiagnosticKind.INFO, "Adding java action block generation subdirectory. ");
		}
		metaDirPath = rootDirPath + DIRECTORY_META;
		File metaDir = new File(metaDirPath);
		if(!metaDir.exists()) {
			metaDir.mkdirs();
			processingEnv.getMessager().printMessage(DiagnosticKind.INFO, "Adding meta-inf subdirectory. ");
		}
		processingEnv.getMessager().printMessage(DiagnosticKind.INFO, "Generation " + OPT_NOTES_DIRECTORY + " used: " + rootDirPath);
	}	
	
	private void emptyDirectories() {
		rootDirPath = processingEnv.getOptions().getOrDefault(OPT_NOTES_DIRECTORY, "C:\\TEMP");
		File rootDir = new File(rootDirPath);
		deleteDir(rootDir);
	}
	
	void deleteDir(File file) {
	    File[] contents = file.listFiles();
	    if (contents != null) {
	        for (File f : contents) {
	            deleteDir(f);
	        }
	    }
	    file.delete();
	}

}
