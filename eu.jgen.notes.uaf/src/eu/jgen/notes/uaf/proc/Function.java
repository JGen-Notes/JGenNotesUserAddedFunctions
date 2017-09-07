package eu.jgen.notes.uaf.proc;

  
public @interface Function {	
	 public String CGName();
	 public boolean useselec() default false;
	 public String dbmsname() default "IEFDB";
	 public boolean impl() default false;
}
