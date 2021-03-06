/**
* Code generated by UserAddedFunctionProcessor
*/
package com.ca.gen.abrt.functions.test;

import static org.junit.Assert.assertTrue;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

import com.ca.gen.abrt.functions.XFAB01;
import com.ca.gen.vwrt.types.IntAttr;
import com.google.inject.Guice;
import com.google.inject.Injector;

import eu.jgen.notes.ab.direct.mgr.ActionBlockModule;
import eu.jgen.notes.ab.direct.mgr.DBMSType;
import eu.jgen.notes.ab.direct.mgr.DirectException;
import eu.jgen.notes.ab.direct.mgr.SessionContext;
import eu.jgen.notes.ab.direct.mgr.SessionManager;
import eu.jgen.notes.ab.direct.mgr.TransactionManagerType;

/**
 * @author
 *
 */
public class XFAB01Tests {

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
		IntAttr result = IntAttr.getInstance();
		XFAB01.XFAB01(new Object(), new SessionContext(sessionManager.getGlobData()), sessionManager.getGlobData(), 2,
				2, result);
		assertTrue(result.get() == 4);
	}

}
