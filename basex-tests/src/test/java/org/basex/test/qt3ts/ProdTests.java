package org.basex.test.qt3ts;

import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;

import org.basex.test.qt3ts.prod.*;

/**
 * Test suite for the "prod" test group.
 *
 * @author BaseX Team 2005-13, BSD License
 * @author Leo Woerteler
 */
@RunWith(Suite.class)
@SuiteClasses({
  ProdAllowingEmpty.class,
  ProdAnnotation.class,
  ProdAxisStep.class,
  ProdAxisStepAbbr.class,
  ProdAxisStepAncestor.class,
  ProdAxisStepAncestorOrSelf.class,
  ProdAxisStepFollowing.class,
  ProdAxisStepFollowingSibling.class,
  ProdAxisStepPreceding.class,
  ProdAxisStepPrecedingSibling.class,
  ProdAxisStepUnabbr.class,
  ProdBaseURIDecl.class,
  ProdBoundarySpaceDecl.class,
  ProdCastExpr.class,
  ProdCastExprDerived.class,
  ProdCastableExpr.class,
  ProdComment.class,
  ProdCompAttrConstructor.class,
  ProdCompCommentConstructor.class,
  ProdCompDocConstructor.class,
  ProdCompElemConstructor.class,
  ProdCompNamespaceConstructor.class,
  ProdCompPIConstructor.class,
  ProdCompTextConstructor.class,
  ProdConstructionDecl.class,
  ProdContextItemDecl.class,
  ProdContextItemExpr.class,
  ProdCopyNamespacesDecl.class,
  ProdCountClause.class,
  ProdDecimalFormatDecl.class,
  ProdDefaultCollationDecl.class,
  ProdDefaultNamespaceDecl.class,
  ProdDirAttributeList.class,
  ProdDirElemConstructor.class,
  ProdDirElemContent.class,
  ProdDirElemContentNamespace.class,
  ProdDirElemContentWhitespace.class,
  ProdDirectConstructor.class,
  ProdEQName.class,
  ProdEmptyOrderDecl.class,
  ProdExtensionExpr.class,
  ProdForClause.class,
  ProdFunctionCall.class,
  ProdFunctionDecl.class,
  ProdGeneralCompEq.class,
  ProdGeneralCompGe.class,
  ProdGeneralCompGt.class,
  ProdGeneralCompLe.class,
  ProdGeneralCompLt.class,
  ProdGeneralCompNe.class,
  ProdGroupByClause.class,
  ProdIfExpr.class,
  ProdInstanceofExpr.class,
  ProdLetClause.class,
  ProdLiteral.class,
  ProdModuleImport.class,
  ProdNameTest.class,
  ProdNamedFunctionRef.class,
  ProdNamespaceDecl.class,
  ProdNodeTest.class,
  ProdOptionDecl.class,
  ProdOptionDeclSerialization.class,
  ProdOrExpr.class,
  ProdOrderByClause.class,
  ProdOrderingModeDecl.class,
  ProdParenthesizedExpr.class,
  ProdPathExpr.class,
  ProdPositionalVar.class,
  ProdPredicate.class,
  ProdQuantifiedExpr.class,
  ProdRequireProhibitFeature.class,
  ProdReturnClause.class,
  ProdSequenceType.class,
  ProdStepExpr.class,
  ProdSwitchExpr.class,
  ProdTreatExpr.class,
  ProdTryCatchExpr.class,
  ProdTypeswitchExpr.class,
  ProdUnorderedExpr.class,
  ProdValueComp.class,
  ProdVarDecl.class,
  ProdVarDeclExternal.class,
  ProdVarDefaultValue.class,
  ProdVersionDecl.class,
  ProdWhereClause.class,
  ProdWindowClause.class
})
public class ProdTests { }
