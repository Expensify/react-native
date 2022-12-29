/**
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @format
 * @flow strict-local
 */

import type {ColorValue} from 'react-native/Libraries/StyleSheet/StyleSheet';

export type TextCodeBlockProp = $ReadOnly<{|
  /**
   * The background color of the text code block.
   */
  backgroundColor?: ?ColorValue,

  /**
   * The border color of the text code block.
   */
  borderColor?: ?ColorValue,

  /**
   * The border radius of the text code block.
   */
  borderRadius?: ?number,

  /**
   * The border width of the text code block.
   */
  borderWidth?: ?number,
|}>;
