// This is a generated file. Not intended for manual editing.
package org.vlang.lang.psi;

import org.jetbrains.annotations.NotNull;

import java.util.List;

public interface VlangJsonCallExpr extends VlangCallExpr {

  @NotNull
  VlangJsonArgumentList getJsonArgumentList();

  @NotNull
  List<VlangExpression> getParameters();

}