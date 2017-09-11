package eu.jgen.notes.tstuaf1.samples;
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
//
//                    Source Code Generated by
//                           CA Gen 8.6
//
//    Copyright (c) 2017 CA Technologies. All rights reserved.
//
//    Name: AB01_OA                          Date: 2017/09/10
//    User: Marek                            Time: 22:43:30
//
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Import Statements
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
import java.lang.*;
import java.io.*;
import java.util.*;
import java.math.*;
import java.sql.*;
import com.ca.gen.vwrt.*;
import com.ca.gen.vwrt.types.*;
import com.ca.gen.vwrt.vdf.*;
import com.ca.gen.csu.exception.*;

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// START OF EXPORT VIEW
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
/**
 * Internal data view storage for: AB01_OA
 **/
public class AB01_OA extends ViewBase implements IExportView, Serializable
{
  // Entity View: EXP
  //        Type: IEF_SUPPLIED
  /**
   * Attribute missing flag for: ExpIefSuppliedCount
   **/
  public char ExpIefSuppliedCount_AS;
  /**
   * Attribute for: ExpIefSuppliedCount
   * Domain: Number
   * Length: 9
   * Decimal Places: 0
   * Decimal Precision: N
   **/
  public int ExpIefSuppliedCount;
  /**
   * Default Constructor
   **/
  
  public AB01_OA()
  {
    reset();
  }
  /**
   * Copy Constructor
   **/
  
  public AB01_OA(AB01_OA orig)
  {
    copyFrom(orig);
  }
  /**
   * Static instance creator function
   **/
  
  public static AB01_OA getInstance()
  {
    return new AB01_OA();
  }
  /**
   * Static free instance method
   **/
  
  public void freeInstance()
  {
  }
  /**
   * clone constructor
   **/
  
  @Override public Object clone()
  	throws CloneNotSupportedException
  {
    return(new AB01_OA(this));
  }
  /**
   * Resets all properties to the defaults.
   **/
  
  public void reset()
  {
    ExpIefSuppliedCount_AS = ' ';
    ExpIefSuppliedCount = 0;
  }
  /**
   * Sets the current state of the instance to the VDF version.
   **/
  public void setFromVDF(VDF vdf)
  {
    throw new RuntimeException("can only execute setFromVDF for a Procedure Step.");
  }
  
  /**
   * Gets the VDF version of the current state of the instance.
   **/
  public VDF getVDF()
  {
    throw new RuntimeException("can only execute getVDF for a Procedure Step.");
  }
  
  /**
   * Sets the current instance based on the passed view.
   **/
  public void copyFrom(IExportView orig)
  {
    this.copyFrom((AB01_OA) orig);
  }
  
  /**
   * Sets the current instance based on the passed view.
   **/
  public void copyFrom(AB01_OA orig)
  {
    ExpIefSuppliedCount_AS = orig.ExpIefSuppliedCount_AS;
    ExpIefSuppliedCount = orig.ExpIefSuppliedCount;
  }
}