package org.basex.query.ast;

import static org.basex.util.Prop.*;
import static org.junit.Assert.*;

import org.basex.query.*;
import org.basex.query.value.item.*;
import org.basex.query.value.node.*;

/**
 * Abstract test class for properties on the Query Plan.
 *
 * @author BaseX Team 2005-17, BSD License
 * @author Leo Woerteler
 */
public abstract class QueryPlanTest extends AdvancedQueryTest {
  /**
   * Checks the query plan and the result.
   * @param qu query
   * @param res result or {@code null} for no comparison
   * @param checks queries on the query plan
   */
  protected static void check(final String qu, final String res, final String... checks) {
    try(QueryProcessor qp = new QueryProcessor(qu, context)) {
      // compile query
      qp.compile();
      // retrieve compiled query plan
      final FDoc plan = qp.plan();
      // compare results
      if(res != null) {
        assertEquals("\nQuery: " + qu + '\n',
            res, normNL(qp.value().serialize().toString()));
      }

      for(final String p : checks) {
        if(new QueryProcessor(p, context).context(plan).value() != Bln.TRUE) {
          fail(NL + "- Query: " + qu + NL + "- Check: " + p + NL +
              "- Plan: " + plan.serialize());
        }
      }
    } catch(final Exception ex) {
      throw new AssertionError(qu, ex);
    }
  }
}
