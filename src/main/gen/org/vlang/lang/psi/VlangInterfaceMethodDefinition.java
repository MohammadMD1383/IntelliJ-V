// This is a generated file. Not intended for manual editing.
package org.vlang.lang.psi;

import com.intellij.psi.PsiElement;
import com.intellij.psi.ResolveState;
import com.intellij.psi.StubBasedPsiElement;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.vlang.lang.stubs.VlangInterfaceMethodDefinitionStub;

public interface VlangInterfaceMethodDefinition extends VlangSignatureOwner, VlangNamedElement, StubBasedPsiElement<VlangInterfaceMethodDefinitionStub> {

  @NotNull
  VlangSignature getSignature();

  @NotNull
  PsiElement getIdentifier();

  @Nullable
  VlangType getTypeInner(@Nullable ResolveState context);

  boolean isPublic();

}