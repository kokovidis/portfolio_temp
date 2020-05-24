import * as React from "react"
import { PropertyControls, ControlType } from "framer"

interface Props {
    value: string
    onValueChange: (value: string) => void
    placeholder: string
    backgroundColor: string
    textColor: string
    width: number
    height: number
}

interface State {
    value: string
    externalValue: string
}

export class SearchBar extends React.Component<Partial<Props>, State> {
    static defaultProps = {
        value: "",
        placeholder: "Search",
        width: 200,
        height: 36,
        backgroundColor: "rgba(142,142,142,0.12)",
        textColor: "black",
    }

    static propertyControls: PropertyControls<Props> = {
        value: { type: ControlType.String, title: "Value" },
        placeholder: { type: ControlType.String, title: "Placeholder" },
        backgroundColor: { type: ControlType.Color, title: "Background" },
        textColor: { type: ControlType.Color, title: "Text" },
    }

    state = {
        value: SearchBar.defaultProps.value,
        externalValue: SearchBar.defaultProps.value,
    }

    static getDerivedStateFromProps(nextProps: Props, prevState: State) {
        const { value } = nextProps
        const { externalValue } = prevState
        if (value !== externalValue) {
            return { value, externalValue: value }
        }
        return null
    }

    onChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        const element = event.nativeEvent.target as HTMLInputElement
        const value = element.value
        this.setState({ ...this.state, value })
        if (this.props.onValueChange) this.props.onValueChange(value)
    }

    render() {
        const { placeholder, backgroundColor, textColor } = this.props
        const { value } = this.state
        return (
            <input
                onChange={this.onChange}
                value={value}
                placeholder={placeholder}
                style={{ ...style, backgroundColor, color: textColor }}
            />
        )
    }
}

const style: React.CSSProperties = {
    borderRadius: 10,
    border: "none",
    paddingLeft: 8,
    paddingRight: 8,
    position: "absolute",
    left: 0,
    right: 0,
    top: 0,
    bottom: 0,
}
