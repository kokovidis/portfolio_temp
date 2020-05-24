import * as React from "react";
import { Frame, PropertyControls, ControlType, FramerEvent } from "framer";

interface Props {
  title: string;
  message: string;
  primary: string;
  secondary: string;
  destructive: boolean;
  tintColor: string;
  destructiveColor: string;
  primaryAction: (event: FramerEvent) => void;
  secondaryAction: (event: FramerEvent) => void;
  width: number;
  height: number;
}

export class AlertView extends React.Component<Partial<Props>> {
  static defaultProps = {
    title: "Current Location Not Available",
    message: "Your current location can not be determined at this time.",
    primary: "OK",
    secondary: "",
    destructive: false,
    tintColor: "#007AFF",
    destructiveColor: "#FF3B30",
    width: 270,
    height: 140
  };

  static propertyControls: PropertyControls<Props> = {
    title: { type: ControlType.String, title: "Title" },
    message: { type: ControlType.String, title: "Message" },
    primary: { type: ControlType.String, title: "Primary" },
    secondary: { type: ControlType.String, title: "Secondary" },
    destructive: { type: ControlType.Boolean, title: "Destructive" },
    destructiveColor: {
      type: ControlType.Color,
      title: " ",
      hidden(props) {
        return !props.destructive;
      }
    },
    tintColor: { type: ControlType.Color, title: "Tint" }
  };

  render() {
    const {
      title,
      message,
      primary,
      secondary,
      destructive,
      tintColor,
      destructiveColor,
      primaryAction,
      secondaryAction,
      width,
      height
    } = this.props;

    return (
      <Frame
        width={width}
        height={height}
        background={"rgba(248,248,248,.82)"}
        backgroundBlur={20}
        radius={14}
        overflow={"hidden"}
        style={{ fontSize: 17, textAlign: "center" }}
      >
        <Frame top={18} bottom={44 + 18} left={16} right={16} background={null}>
          <span style={{ display: "block", marginBottom: 4 }}>{title}</span>
          <span style={{ display: "block", fontSize: 13 }}>{message}</span>
        </Frame>
        <Frame
          height={44}
          width={width}
          left={0}
          bottom={0}
          borderStyle={"solid"}
          borderColor={borderColor}
          borderWidth={{ top: 0.5 }}
          background={null}
          style={{ fontSize: 17, color: tintColor }}
        >
          {secondary && (
            <Frame
              height={44}
              left={0}
              width={"50%"}
              background={null}
              borderColor={borderColor}
              borderStyle={"solid"}
              borderWidth={{ right: 0.5 }}
              onTap={secondaryAction}
            >
              {secondary}
            </Frame>
          )}
          <Frame
            height={44}
            right={0}
            width={secondary ? "50%" : "100%"}
            background={null}
            style={{ color: destructive ? destructiveColor : tintColor }}
            onTap={primaryAction}
          >
            {primary}
          </Frame>
        </Frame>
      </Frame>
    );
  }
}

const borderColor = "rgba(63,63,63,.3)";
