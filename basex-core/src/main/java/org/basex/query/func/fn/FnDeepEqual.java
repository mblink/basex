package org.basex.query.func.fn;

import org.basex.query.*;
import org.basex.query.expr.*;
import org.basex.query.func.*;
import org.basex.query.iter.*;
import org.basex.query.util.*;
import org.basex.query.util.collation.*;
import org.basex.query.value.*;
import org.basex.query.value.item.*;
import org.basex.util.*;

/**
 * Function implementation.
 *
 * @author BaseX Team 2005-24, BSD License
 * @author Christian Gruen
 */
public final class FnDeepEqual extends StandardFunc {
  @Override
  public Bln item(final QueryContext qc, final InputInfo ii) throws QueryException {
    final Iter input1 = arg(0).iter(qc), input2 = arg(1).iter(qc);
    final Collation collation = toCollation(arg(2), qc);
    final DeepEqualOptions options = toOptions(arg(3), new DeepEqualOptions(), qc);

    final DeepEqual de = new DeepEqual(info, collation, qc, options);
    final Value ie = options.get(DeepEqualOptions.ITEMS_EQUAL);
    if(!ie.isEmpty()) de.itemsEqual = toFunction(ie, 2, qc);

    return Bln.get(de.equal(input1, input2));
  }

  @Override
  protected Expr opt(final CompileContext cc) {
    final Expr input1 = arg(0), input2 = arg(1);
    if(!defined(2)) {
      // do not compare identical arguments
      if(!input1.seqType().mayBeFunction() && !input2.seqType().mayBeFunction() &&
          input1.equals(input2) && !input1.has(Flag.NDT)) return Bln.TRUE;
      // reject arguments of different size
      final long size1 = input1.size(), size2 = input2.size();
      if(size1 != -1 && size2 != -1 && size1 != size2) return Bln.FALSE;
    }
    return this;
  }
}
