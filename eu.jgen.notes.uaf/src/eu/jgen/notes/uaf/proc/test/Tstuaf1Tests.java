package eu.jgen.notes.uaf.proc.test;

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
 * @author Marek Stankiewicz
 *
 */
public class Tstuaf1Tests {

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
	public void onlyImportTest() {
		 IntAttr result = IntAttr.getInstance();
		 XFAB01.XFAB01(new Object(), new SessionContext(sessionManager.getGlobData()), sessionManager.getGlobData(), 1, 1, result);
		 System.out.println(result.get());
	}


	



}
